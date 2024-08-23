function [points_2D, T] = projectToPlane(points, normal, T)
    %PROJECTTOPLANE si occupa di proiettare i punti su un piano definito dalla normale
    % points: matrice nx3, contente i punti da proiettare
    % normal: vettore che definisce il piano di proiezione
    % T: è una matrice di rotazione, se fornita, viene utilizzata per la trasformazione; altrimenti, viene calcolata
    % points_2D: punti in 2D, proiettati sul piano specificato
    
    if nargin < 3
        % Controlla se la normale è parallela o antiparallela all'asse z
        if all(normal == [0, 0, 1]) || all(normal == [0, 0, -1])
            % Non c'è bisogno di rotazione, il piano è già allineato
            T = eye(3);
        else
            % Crea una matrice di rotazione che allinea la normale con l'asse z
            z_axis = [0, 0, 1];
            v = cross(normal, z_axis);
            s = norm(v);
            c = dot(normal, z_axis);
            vx = [0, -v(3), v(2); v(3), 0, -v(1); -v(2), v(1), 0];
            T = eye(3) + vx + (vx * vx) * ((1 - c) / (s^2));
        end
    end
    
    % Applica la trasformazione ai punti
    points_transformed = (T * points')';
    
    % Scarta la coordinata z (proiezione su 2D)
    points_2D = points_transformed(:, 1:2);
end