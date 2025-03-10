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
    if ((i-1) %% 365 == 0) {
      meteo_an[i] = 1L
    }
    else{
      meteo_an[i] <- proba_trans_vectorized(u[i - 1L], y[meteo_an[i - 1L], 1L], y[meteo_an[i - 1L], 2L])
    }
  }
  meteo_an
}

# Simulation des remboursements optimisée
nb_acc_a <- function(params, n.simul) {
  transition_matrix <- define_transition_matrix(params$ptrans)
  meteo_simul <- meteo(365*n.simul, 1L, transition_matrix)
  dim(meteo_simul) <- c(365,n.simul)
  
  # Calcul vectorisé des accidents
  accident_probs <- params$pacc[meteo_simul]
  accidents <- rbinom(length(accident_probs), params$N, accident_probs)
  accidents_matrix <- matrix(accidents, nrow = 365, ncol = n.simul)
  
  # Somme des accidents pour chaque simulation
  total_accidents <- colSums(accidents_matrix)
  
  total_accidents
}


nb_acc_b <- function(params, n.simul) {
  # Pré-calculer la matrice de transition (une seule fois)
  transition_matrix <- define_transition_matrix(params$ptrans)
  
  # Préparer un vecteur pour stocker les résultats
  resultats <- sapply(seq_len(n.simul), function(i) {
    # Génération des états météo pour une simulation
    meteo_states <- meteo(365L * params$N, 1L, transition_matrix)
    
    # Calcul des probabilités d'accidents
    accident_probs <- params$pacc[meteo_states]
    
    # Génération des accidents avec probabilités
    accidents <- rbinom(365L * params$N, 1, prob = accident_probs)
    
    # Calcul du total d'accidents
    total_accidents <- sum(accidents)
    
    total_accidents
  })
  
  return(resultats)
}

acc_a = nb_acc_a(list(alpha=2,x0=1,eta=3.1,pacc=c(0.15,0.75,0.1), ptrans=c(0.5,0.1,0.6,0.3),N=500,s=1000), 100)

acc_b = nb_acc_b(list(alpha=2,x0=1,eta=3.1,pacc=c(0.15,0.75,0.1), ptrans=c(0.5,0.1,0.6,0.3),N=500,s=1000), 100)

hist(x = acc_a)

# Test t de Student
t_test_result <- t.test(acc_a, acc_b)

# Afficher les résultats
print(t_test_result)

# Test de Wilcoxon
wilcoxon_result <- wilcox.test(acc_a, acc_b)

# Afficher les résultats
print(wilcoxon_result)
