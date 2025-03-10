# Points de contrôle séparés pour le calcul
U_POINTS_LOW <- c(0, 0.001, 0.005, 0.025, 0.075, 0.2)
U_POINTS_HIGH <- c(0.8, 0.9, seq(0.95, 0.999, length.out = 3))

create_F_inv_linear <- function() {
  last_params <- list()
  cached_terms <- list()
  cached_x_points <- NULL
  cached_slopes <- NULL
  cached_intercepts <- NULL
  
  function(y, x0, alpha, eta) {
    current_params <- list(x0 = x0, alpha = alpha, eta = eta)
    
    if (length(last_params) == 0 || !identical(current_params, last_params)) {
      # Calcul et mise en cache des termes communs
      one_minus_eta <- 1 - eta
      alpha_plus_x0 <- alpha + x0
      log_alpha <- log(alpha)
      log_alpha_plus_x0 <- log(alpha_plus_x0)
      term1 <- exp(log_alpha_plus_x0 * one_minus_eta)
      term2 <- exp(log_alpha * one_minus_eta)
      lambda <- one_minus_eta / (term1 - 2 * term2)
      
      cached_terms <<- list(
        one_minus_eta = one_minus_eta,
        alpha_plus_x0 = alpha_plus_x0,
        term1 = term1,
        term2 = term2,
        lambda = lambda
      )
      
      # Calcul des images pour les points bas
      x_points_low <- sapply(U_POINTS_LOW, function(u) {
        alpha_plus_x0 - exp(log(term1 - (u * one_minus_eta) / lambda) / one_minus_eta)
      })
      
      # Calcul des images pour les points hauts
      x_points_high <- sapply(U_POINTS_HIGH, function(u) {
        exp(log((u * one_minus_eta) / lambda - term1 + 2 * term2) / one_minus_eta) + x0 - alpha
      })
      
      # Fusion des points de contrôle et leurs images
      U_POINTS_ALL <- c(U_POINTS_LOW, U_POINTS_HIGH)
      cached_x_points <<- c(x_points_low, x_points_high)
      
      # Calcul des pentes et intercepts pour l'interpolation
      dx <- diff(cached_x_points)
      du <- diff(U_POINTS_ALL)
      cached_slopes <<- dx / du
      cached_intercepts <<- cached_x_points[-length(cached_x_points)] - 
        U_POINTS_ALL[-length(U_POINTS_ALL)] * cached_slopes
      
      last_params <<- current_params
    }
    
    # Interpolation linéaire pour tous les points
    idx_segment <- findInterval(y, c(U_POINTS_LOW, U_POINTS_HIGH))
    result <- cached_slopes[idx_segment] * y + cached_intercepts[idx_segment]
    
    return(result)
  }
}

# Fonction pour générer des échantillons aléatoires
rremb <- function(n, params) {
  f_inv_linear <- create_F_inv_linear()
  u <- runif(n, 0,0.999)
  return(f_inv_linear(u, params$x0, params$alpha, params$eta))
}


# Fonctions de transition et météo optimisées
proba_trans_vectorized <- function(x, p_0, p_1) {
  1L + (x > p_0) + (x > (p_0 + p_1))
}

define_transition_matrix <- function(ptrans) {
  t(matrix(
    c(1 - ptrans[1], ptrans[1], 0,
      ptrans[2], 1 - sum(ptrans[2:3]), ptrans[3],
      0, 1 - ptrans[4], ptrans[4]),
    nrow = 3L
  ))
}

meteo <- function(n,meteo_0, y) {
  meteo_an <- integer(n)
  meteo_an[1L] <- meteo_0
  u <- runif(n - 1L)
  for (i in 2L:n) {
    if (meteo_an[i] == 0) {
      meteo_an[i] <- proba_trans_vectorized(u[i - 1L], y[meteo_an[i - 1L], 1L], y[meteo_an[i - 1L], 2L])
      if (i %% 365 == 0 & i<n) {
        meteo_an[i+1] = 1L
      }
    }
  }
  meteo_an
}

# Simulation des remboursements optimisée
remb_simul_a <- function(params, n.simul) {
  transition_matrix <- define_transition_matrix(params$ptrans)
  meteo_simul <- meteo(365*n.simul, 1L, transition_matrix)
  dim(meteo_simul) <- c(365,n.simul)
  
  # Calcul vectorisé des accidents
  accident_probs <- params$pacc[meteo_simul]
  accidents <- rbinom(length(accident_probs), params$N, accident_probs)
  accidents_matrix <- matrix(accidents, nrow = 365, ncol = n.simul)
  
  # Somme des accidents pour chaque simulation
  total_accidents <- colSums(accidents_matrix)
  
  # Simulation des remboursements pour chaque simulation
  resultats <- sapply(total_accidents, function(acc) sum(rremb(acc, params)))
  
  return(resultats)
}


remb_simul_b <- function(params, n.simul) {
  # Pré-calculer la matrice de transition (une seule fois)
  transition_matrix <- define_transition_matrix(params$ptrans)
  
  # Préparer un vecteur pour stocker les résultats
  resultats <- numeric(n.simul)
  
  for (i in seq_len(n.simul)) {
    # Génération des états météo pour une simulation
    meteo_states <- meteo(365L * params$N, 1L, transition_matrix)
    
    # Calcul des probabilités d'accidents
    accident_probs <- params$pacc[meteo_states]
    
    # Génération des accidents avec probabilités
    accidents <- rbinom(365L * params$N, 1, prob = accident_probs)
    
    # Calcul du total d'accidents
    total_accidents <- sum(accidents)
    
    # Calcul des remboursements pour cette simulation
    resultats[i] <- sum(rremb(total_accidents, params))
  }
  
  return(resultats)
}

# Fonction pour calculer la moyenne et l'intervalle de confiance
calculate_statistics <- function(remboursements,params) {
  differences <- remboursements - params$s
  differences_positive <- differences[differences > 0]
  
  if (length(differences) == 0) {
    return(list(ms = 0, demi.largeur = 0))
  }
  
  moyenne <- mean(differences)
  ecart <- sd(differences) / sqrt(length(differences))
  
  list(ms = moyenne, demi.largeur = 1.96 * ecart)
}

msa <- function(n.simul, params) {
  remboursements <- remb_simul_a(params, n.simul)
  

  return(calculate_statistics(remboursements,params))
}

msb <- function(n.simul, params) {
  remboursements <- remb_simul_b(n.simul = n.simul, params = params)
  
  # Calcul des différences positives
  return(calculate_statistics(remboursements,params))
}


library(Rcpp)

msb.c <- function(n.simul, params) {
  # Définir et compiler la fonction C++ à la volée
  Rcpp::cppFunction('
  Rcpp::List msb_c_function(int n_simul, Rcpp::List params, Rcpp::Function rremb) {
    // Extraire les paramètres
    Rcpp::NumericVector ptrans = params["ptrans"];
    Rcpp::NumericVector pacc = params["pacc"];
    double s = params["s"];
    int N = params["N"];
    
    // Convertir ptrans en une matrice de transition
    Rcpp::NumericMatrix transition_matrix(3, 3);
    transition_matrix(0, 0) = 1 - ptrans[0];
    transition_matrix(0, 1) = ptrans[0];
    transition_matrix(0, 2) = 0;
    transition_matrix(1, 0) = ptrans[1];
    transition_matrix(1, 1) = 1 - (ptrans[1] + ptrans[2]);
    transition_matrix(1, 2) = ptrans[2];
    transition_matrix(2, 0) = 0;
    transition_matrix(2, 1) = 1 - ptrans[3];
    transition_matrix(2, 2) = ptrans[3];
    
    // Préparer les résultats
    Rcpp::NumericVector remboursements_simul(n_simul);
    
    // Générer les simulations
    for (int sim = 0; sim < n_simul; ++sim) {
      // Générer les états météo
      Rcpp::IntegerVector meteo_states(365 * N);
      meteo_states[0] = 1; // État initial
      
      for (int i = 1; i < 365 * N; ++i) {
        double u = R::runif(0, 1);
        int current_state = meteo_states[i - 1] - 1;
        if (u <= transition_matrix(current_state, 0)) {
          meteo_states[i] = 1;
        } else if (u <= transition_matrix(current_state, 0) + transition_matrix(current_state, 1)) {
          meteo_states[i] = 2;
        } else {
          meteo_states[i] = 3;
        }
      }
      
      // Générer les accidents
      int total_accidents = 0;
      for (int i = 0; i < 365 * N; ++i) {
        total_accidents += R::rbinom(1, pacc[meteo_states[i] - 1]);
      }
      
      // Calculer les remboursements
      Rcpp::NumericVector remb_values = rremb(total_accidents, params);
      remboursements_simul[sim] = Rcpp::sum(remb_values);
    }
    
    // Calcul des différences positives
    Rcpp::NumericVector differences = remboursements_simul - s;
    Rcpp::NumericVector positive_differences = differences[differences > 0];
    
    // Calcul des métriques
    double moyenne = Rcpp::mean(positive_differences);
    double ecart = Rcpp::sd(positive_differences) / std::sqrt(positive_differences.size());
    
    // Retourner les résultats
    return Rcpp::List::create(
      Rcpp::Named("ms") = moyenne,
      Rcpp::Named("demi.largeur") = 1.96 * ecart
    );
  }
  ')
  
  # Appeler la fonction C++ compilée
  msb_c_function(n.simul, params, rremb)
}