# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, extremevalues)

## Load data
data <- read.csv("imoveis_pel26052016.csv", sep = ";", dec = ",")
data <- data.table(data)

## Remove some NAs
data <- data[area != "NA"]
data <- data[,preco := preco/1000]
data[,cidade := "Pelotas"]
data <- data[,cidade := droplevels(cidade)]

## Remove outliers
outs <- apply(data[,.(preco,quartos,suites,vagas,area)], 2, getOutliers)
outs_ind <- list()
for (i in 1:length(outs)) {
  outs_ind[[i]] <- outs[[i]]$iRight
}
outs_ind <- unique(unlist(outs_ind))
data <- data[!outs_ind]
data[,bairro := as.factor(toupper(bairro))]

# Apartamentos dos principais bairros na variavel aptos
aptos <- subset(data, tipo == "Apartamento")
n_bairro <- aptos[, length(preco), by = bairro]
princ_bairros <- as.character(n_bairro[V1 > 25, bairro])
aptos <- subset(data, tipo == "Apartamento" & bairro %in% princ_bairros)
aptos$bairro <- aptos[, droplevels(bairro)]
aptos$tipo <- aptos[, droplevels(tipo)]
aptos$endereco <- aptos[, droplevels(endereco)]
