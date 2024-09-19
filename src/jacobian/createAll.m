function createAll

    clc; close all; clear;
    
    %% Importo nel workspace il modello e le matrici di incidenza 
    addpath('./incidence_matrices/');
    createIncidenceMatrices();
    
    % % Tipo di mesh
    % mesh_type = evalin('base','meshdataTypesList');
    
    % Tabella mesh-nodi
    mesh_elements = evalin('caller', 'incidenceMatrices.arrayNodesElements');
    
    % Tabella nodi-coordinate 
    coord_nodes = evalin('caller', 'incidenceMatrices.arrayNodalCoordinates');
    
    for i = 1: size(coord_nodes,1)
        for j = 1:size(coord_nodes,2)
            if (0 < coord_nodes(i,j)) && (coord_nodes(i,j) < 1e-15)
                coord_nodes(i,j) = double(0);
            end
        end
    end

    %% Costruzione della tabella elementi di mesh-coordinate nodali
    
    % Numero di elementi di mesh
    numElements = size(mesh_elements, 1);

    % Numero di nodi per elemento di mesh
    numNodes = size(mesh_elements, 2);

    % Prealloco un array per salvare le coordinate di una mesh
    coord_element = zeros(numNodes,3);
    
    % Prealloco un cell array per tener traccia delle coordinate di tutti
    % gli elementi di mesh
    coord_mesh = cell(size(mesh_elements,1),1);
    
    %Popolazione degli array
    for i = 1:size(mesh_elements,1)
        for j = 1:size(mesh_elements,2)
            node = mesh_elements(i,j);
            coord = coord_nodes(node,:);
            coord_element(j,:) = coord(1,:);
        end
        coord_mesh{i} = coord_element;
    
        coord_element(:,:) = [];
    end

    %% Trasformo il cell array in una tabella
    coord_mesh_table = coord_mesh';
    variableNames = {'x', 'y', 'z'};
    
    % Iterare su tutte le matrici
    for i = 1:length(coord_mesh_table)
        coord_mesh_table{i} = array2table(coord_mesh{i},'VariableNames', variableNames);
    end
    
    nodeLabels = strcat('e_', string(1:size(coord_mesh_table, 2)));
    tableCoords = cell2table(coord_mesh_table,'VariableNames', nodeLabels,'RowNames',"coordinates");
    assignin('base', 'tableCoords', tableCoords);
    
    %% Calcolo della jacobiana
    
    % Prealloco una cella per memorizzare le funzioni di forma
    shapeFunction = cell(numNodes,1);
    
    masterElement = [];
    
    searchedString = "pyr";

    if searchedString == "hex"

        % Definizione delle coordinate locali (dell'elemento master)
        masterElement = [ 0 0 0; 1 0 0; 0 1 0; 1 1 0; 0 0 1; 1 0 1; 0 1 1; 1 1 1];

        % Calcolo le funzioni di forma per un elemento esaedrico lineare
        syms xi eta zeta
        N = @(xi_i, eta_i, zeta_i)(...
            (((1-xi)^(1-xi_i)) * xi^xi_i) * (((1-eta)^(1-eta_i)) * eta^eta_i) * (((1-zeta)^(1-zeta_i)) * zeta^zeta_i));

    elseif searchedString == "tet"
        masterElement = [0 0 0; 1 0 0; 0 1 0; 0 0 1];

        syms xi eta zeta
        N = @(xi_i, eta_i, zeta_i)(...
            (1-xi-eta-zeta)+xi_i*(2*xi+eta+zeta-1)+eta_i*(xi+2*eta+zeta-1)+zeta_i*(xi+eta+2*zeta-1));

    elseif searchedString == "prism"
        masterElement = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 0 1; 0 1 1];
        
        % Calcolo le funzioni di forma per un elemento esaedrico lineare
        syms xi eta zeta
        N = @(xi_i, eta_i, zeta_i)(...
            ((1-xi-eta)^(1-xi_i-eta_i))*(xi^xi_i)*(eta^eta_i)*((1-zeta)^(1-zeta_i))*(zeta^zeta_i));

    elseif searchedString == "pyr"
        masterElement = [0 0 0; 1 0 0; 0 1 0; 1 1 0; 0.5 0.5 1];

        syms xi eta zeta
        N = @(xi_i, eta_i, zeta_i)(...
             ((1-xi)^(1-xi_i)*xi^xi_i*(1-eta)^(1-eta_i)*eta^eta_i*(1-zeta)*(1-zeta_i)) + (zeta*zeta_i));

    end

    for i = 1:numNodes
        xi_i = masterElement(i,1);
        eta_i = masterElement(i,2);
        zeta_i = masterElement(i,3);

        shapeFunction{i} = N(xi_i, eta_i, zeta_i);
    end

    dN_dxi = sym(zeros(1,numNodes));
    dN_deta = sym(zeros(1,numNodes));
    dN_dzeta = sym(zeros(1,numNodes));

    % Calcolo le derivate per costruire la jacobiana
    for i = 1:size(shapeFunction)
        dN_dxi(1,i) = diff(shapeFunction{i},xi);
        dN_deta(1,i) = diff(shapeFunction{i},eta);
        dN_dzeta(1,i) = diff(shapeFunction{i},zeta);
    end

    % Definisco le coordinate locali (ad esempio il punto centrale della mesh)
    local_x = 0.5;
    local_y = 0.5;
    local_z = 0;
    
    % Calcolo le derivate nel punto stabilito
    dN_dxi = subs(dN_dxi, {xi, eta, zeta} , {local_x,local_y,local_z});
    dN_deta = subs(dN_deta, {xi, eta, zeta} , {local_x,local_y,local_z});
    dN_dzeta = subs(dN_dzeta, {xi, eta, zeta} , {local_x,local_y,local_z});

    %Calcolo delle derivate globali (matrice Jacobiana)  
    Jacobian = cell(numElements,1);
    Jacobian_info = cell (numElements,1);
    tableJacobian = table();
    
    for i = 1 : numElements
        X = coord_mesh{i}(:,1);
        Y = coord_mesh{i}(:,2);
        Z = coord_mesh{i}(:,3);
    
        J = zeros(3, 3);
        J(1, 1) = sum(dN_dxi * X) ;
        J(1, 2) = sum(dN_deta * X) ;
        J(1, 3) = sum(dN_dzeta * X);
    
        J(2, 1) = sum(dN_dxi * Y) ;
        J(2, 2) = sum(dN_deta * Y) ;
        J(2, 3) = sum(dN_dzeta * Y);
    
        J(3, 1) = sum(dN_dxi * Z); 
        J(3, 2) = sum(dN_deta * Z); 
        J(3, 3) = sum(dN_dzeta * Z);

        det_J = det(J);
        inv_J = inv(J);
        det_inv = det(inv_J);

        Jacobian{i} = J;
        Jacobian_info{i} = {array2table(J), det_J, array2table(inv_J), det_inv};
        variableNames = {'Jacobiana', 'Determinante', 'Inversa', 'Determinante inversa'};
        tableJacobian(i,:) = cell2table(Jacobian_info{i},'VariableNames', variableNames);
    end
    
    nodeLabels = strcat('e_', string(1:size(coord_mesh_table, 2)));
    tableJacobian.Properties.RowNames = nodeLabels;

    assignin('base', 'Jacobian_info', tableJacobian);

    %% Calcolo la matrice di trasformazione
    transformation_matrices = cell(size(mesh_elements,1),1);

    for i = 1 : numElements
        refCoord = [coord_mesh{i}(1,1) coord_mesh{i}(1,2) coord_mesh{i}(1,3)];
        T = [Jacobian{i}, refCoord'; 0 0 0 1];
        T = round(T,10);
        transformation_matrices{i} = T;
    end
    
    nodeLabels = strcat('e_', string(1:size(coord_mesh_table, 2)));
    transformationTable = cell2table(transformation_matrices','VariableNames', nodeLabels, "RowNames","transformation Matrices");
    assignin('base', 'transformationMatrices', transformationTable);

    % Applicare la trasformazione all'elemento master
    % Aggiungere una colonna di 1 per ogni punto dell'elemento master per moltiplicare con T
    masterElementAugmented = [masterElement, ones(size(masterElement, 1), 1)];  % Aggiungi colonna di 1

    % Trasformare i punti dell'elemento master utilizzando la matrice T
    transformedElement = (transformation_matrices{8} * masterElementAugmented')';  % Moltiplicazione matriciale

    % Rimuovere la colonna aggiuntiva (quella di 1 usata per la traslazione)
    transformedElement = transformedElement(:, 1:3);

    % Visualizzare l'elemento trasformato
    disp('Elemento di mesh ottenuto applicando la trasformazione:');
    disp(transformedElement);

end