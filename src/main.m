import com.comsol.model.*
import com.comsol.model.util.*

close all; clear all; clc;

% Connessione a COMSOL e caricamento del modello

disp("Inizio il caricamento del modello...");
model = mphload('C:\Users\stolf\dev\Progetto Modelli Numerici per Campi e Circuiti\MATSOL\src\Progetto_GruppoMatlab.mph');
disp("Caricamento terminato!");

mphmodel(model);