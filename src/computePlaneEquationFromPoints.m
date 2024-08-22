function [plane_eq] = computePlaneEquationFromPoints(p1, p2, p3)
    % Calcola l'equazione del piano dato tre punti non allineati
    % p1, p2, p3: i tre punti del piano [x, y, z]
    
    % Calcola i vettori del piano
    v1 = p2 - p1;
    v2 = p3 - p1;
    
    % Calcola il vettore normale del piano
    normal = cross(v1, v2);
    normal = normal / norm(normal); % Normalizza il vettore normale
    
    % Calcola il termine d dell'equazione del piano
    d = -dot(normal, p1);
    
    % Costruisci l'equazione del piano
    plane_eq = [normal, d];
    
    % Normalizza il coefficiente per garantire consistenza
    norm_factor = norm(plane_eq(1:3));
    plane_eq = plane_eq / norm_factor; % Trasforma la colonna in una riga e normalizza
    
    % Assicura che il segno sia positivo confrontando il massimo valore assoluto
    [~, idx] = max(abs(plane_eq(1:3)));
    if plane_eq(idx) < 0
        plane_eq = -plane_eq;
    end
end