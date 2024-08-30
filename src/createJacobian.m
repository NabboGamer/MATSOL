function createJacobian

    clc; close all; clear;
    
    %% Importo nel workspace il modello e le matrici di incidenza 
    createIncidenceMatrices();
    
    % Modello
    model = evalin('base','model');
    
    % % Tipo di mesh
    % mesh_type = evalin('base','meshdataTypesList');
    
    % Orientamento della mesh
    axistype = model.geom('geom2').feature('blk1').getString('axistype');
    
    % Tabella mesh-nodi
    mesh_elements = table2array(evalin('caller', 'tableNodesElements'));
    
    % Tabella nodi-coordinate 
    coord_nodes = table2array(evalin('caller', 'tableNodalCoordinates'));
    
    for i = 1: size(coord_nodes,1)
        for j = 1:size(coord_nodes,2)
            if (0 < coord_nodes(i,j)) && (coord_nodes(i,j) < 1e-15)
                coord_nodes(i,j) = double(0);
            end
        end
    end
    
    %% Costruzione della tabella elementi di mesh-coordinate nodali
    
    % Definizione delle coordinate locali (dell'elemento master)
    global_hex = [ 0 0 0; 1 0 0; 0 1 0; 1 1 0; 0 0 1; 1 0 1; 0 1 1; 1 1 1];
    
    % Prealloco un array per salvare le coordinate di una mesh
    coord_element = [];
    
    % Prealloco un cell array per tener traccia delle coordinate di tutti
    % gli elementi di mesh
    coord_mesh = cell(size(mesh_elements,1),1);
    
    % Controllo eventuali "rotazioni" dell'elemento master
    global_hex_rot = global_hex;
    
    % % % Verifico "l'orientamento" della mesh
    % if axistype == 'spherical'
    %     axis = model.geom('geom2').feature('blk1').getDoubleArray('axis');
    %     theta = axis(1)
    %     phi = axis(2)
    % 
    %     % Asse unitario
    %     r = 1;
    %     
    %     % Calcola le coordinate cartesiane
    %     x_ax = r * sin(phi) * cos(theta);
    %     y_ax = r * sin(phi) * sin(theta);
    %     z_ax = r * cos(phi);
    %     
    %     % Restituisci il vettore cartesiano
    %     v_cart = [x_ax; y_ax; z_ax]
    % 
    %     % Normalize the input vectors
    %     v1 = [0 0 1] / norm([0 0 1]);
    %     v2 = v_cart / norm(v_cart);
    %         
    %     % Compute the cross product and dot product
    %     v = cross(v1, v2);         % Axis of rotation
    %     c = dot(v1, v2);           % Cosine of the angle
    %     s = norm(v);               % Sine of the angle
    %         
    %     % Skew-symmetric cross-product matrix of v
    %     vx = [   0   -v(3)  v(2);
    %              v(3)   0   -v(1);
    %             -v(2)  v(1)   0  ];
    %         
    %     % Rodrigues' rotation formula
    %     R = eye(3) + vx + (vx^2) * ((1 - c) / (s^2));
    %     
    %     global_hex_rot = global_hex_rot * R
    %     %global_hex_rot = double(sortrows(global_hex_rot,[3 1 2]));
    % end
    
    if axistype == 'y'
        theta = deg2rad(180);
    
        Ry = [cos(theta), 0, sin(theta);
               0, 1, 0;
               -sin(theta), 0, cos(theta)];
    
        Ry = round(Ry, 10);
    
        global_hex_rot = global_hex_rot * Ry;
        global_hex_rot = (sortrows(global_hex_rot,[3 2 1]));
    
    end
    
    if axistype == 'x'
        theta = deg2rad(90);
    
        Rx = [1, 0, 0;
          0, cos(theta), -sin(theta);
          0, sin(theta), cos(theta)];
    
       global_hex_rot = global_hex_rot * Rx;
       global_hex_rot = double(sortrows(global_hex_rot,[3 1 2]));
    end
    
    %Popolazione degli array
    for i = 1:size(mesh_elements,1)
        for j = 1:size(mesh_elements,2)
            node = mesh_elements(i,j);
            coord = coord_nodes(node,:);
            coord_element = [coord_element; coord];
        end
        coord_mesh{i} = coord_element;
    
        coord_element = [];
    end
    %% Trasformo il cell array in una tabella
    coord_mesh_table = coord_mesh';
    variableNames = {'x', 'y', 'z'};
    
    % Iterare su tutte le matrici
    for i = 1:length(coord_mesh_table)
        coord_mesh_table{i} = array2table(coord_mesh{i},'VariableNames', variableNames);
    end
    
    variableNames = {'e_1', 'e_2', 'e_3', 'e_4', 'e_5', 'e_6', 'e_7', 'e_8'};
    tableCoords = cell2table(coord_mesh_table,'VariableNames', variableNames);
    assignin('base', 'tableCoords', tableCoords);
    
    %% Calcolo della jacobiana
    
    % Numero di elementi di mesh
    numElements = size(mesh_elements, 2);
    
    % %Numero di nodi componenti l'elemento di mesh
    % numNodes = size(mesh_elements, 1);
    
    % Prealloco una cella per memorizzare le funzioni di forma
    shapeFunction = cell(numElements,1);
    
    % Calcolo le funzioni di forma per un elemento esaedrico lineare
    syms xi eta zeta
    N = @(xi_i, eta_i, zeta_i)[
        (((1-xi)^(1-xi_i)) * xi^xi_i) * (((1-eta)^(1-eta_i)) * eta^eta_i) * (((1-zeta)^(1-zeta_i)) * zeta^zeta_i)];
    
    for i = 1:numElements
        xi_i = global_hex(i,1);
        eta_i = global_hex(i,2);
        zeta_i = global_hex(i,3);
    
        shapeFunction{i} = N(xi_i, eta_i, zeta_i);
    end
    
    % Prealloco 3 celle per memorizzare le derivate parziali
    dN_dxi = cell(numElements,1);
    dN_deta = cell(numElements,1);
    dN_dzeta = cell(numElements,1);
    
    % Calcolo le derivate per costruire la jacobiana
    for i = 1:numElements
        dN_dxi{i} = diff(shapeFunction{i},xi);
        dN_deta{i} = diff(shapeFunction{i},eta);
        dN_dzeta{i} = diff(shapeFunction{i},zeta);
    end
    
    % Definisco le coordinate locali (ad esempio il punto centrale della mesh)
    local_x = 0.5;
    local_y = 0.5;
    local_z = 0.5;
    
    % Calcolo le derivate nel punto stabilito
    dN_dxi = subs(dN_dxi, {xi, eta, zeta} , {local_x,local_y,local_z});
    dN_deta = subs(dN_deta, {xi, eta, zeta} , {local_x,local_y,local_z});
    dN_dzeta = subs(dN_dzeta, {xi, eta, zeta} , {local_x,local_y,local_z});
    
    %Calcolo delle derivate globali (matrice Jacobiana)
    X = coord_mesh{8}(:,1);
    Y = coord_mesh{8}(:,2);
    Z = coord_mesh{8}(:,3);
    
    % Offset dell'elemento di mesh i-esimo
    X_ref = coord_mesh{8}(:,1);
    Y_ref = coord_mesh{8}(:,2);
    Z_ref = coord_mesh{8}(:,3);
    
    refCoord = [X_ref Y_ref Z_ref]; 
    
    J = zeros(3, 3);
    J(1, 1) = sum(dN_dxi .* X) ;
    J(1, 2) = sum(dN_deta .* X) ;
    J(1, 3) = sum(dN_dzeta .* X);
    
    J(2, 1) = sum(dN_dxi .* Y) ;
    J(2, 2) = sum(dN_deta .* Y) ;
    J(2, 3) = sum(dN_dzeta .* Y);
    
    J(3, 1) = sum(dN_dxi .* Z); 
    J(3, 2) = sum(dN_deta .* Z); 
    J(3, 3) = sum(dN_dzeta .* Z);
    
    %% Verifico la trasformazione
    
    transformed = global_hex_rot * J;
    
    %Trova l'offset dell'elemento di mesh considerato
    if min(refCoord(:,1)) < 0
        x_offset = max(refCoord(:,1));
    else
        x_offset = min(refCoord(:,1));
    end
    
    if min(refCoord(:,2)) < 0
        y_offset = max(refCoord(:,2));
    else
        y_offset = min(refCoord(:,2));
    end
    
    if min(refCoord(:,3)) < 0
        z_offset = max(refCoord(:,3));
    else
        z_offset = min(refCoord(:,3));
    end
    
    result = double([transformed(:,1) + x_offset transformed(:,2) + y_offset transformed(:,3) + z_offset]);
    disp(result);
    
    prova = [0.5 0.5 0.5] * J;
    prova = [prova(1) + x_offset prova(2) + y_offset prova(3) + z_offset];
    disp(prova);
end