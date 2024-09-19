function createAll2Order

    clc; close all; clear;
    
    %% Importo nel workspace il modello e le matrici di incidenza 
    addpath('../incidence_matrices/');
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
            if node ~= 0
                coord = coord_nodes(node,:);
                coord_element(j,:) = coord(1,:);
            end
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
    

  masterElement = [0 0 0; 0.5 0 0; 1 0 0; 0 0.5 0; 0.5 0.5 0; 1 0.5 0; 0 1 0;...
                   0.5 1 0; 1 1 0; 0.25 0.25 0.5; 0.75 0.25 0.5; 0.25 0.75 0.5; 0.75 0.75 0.5; 0.5 0.5 1];

  meshElement = coord_mesh{1};
    
    %% Calcolo la trasformazione
    A = [masterElement, ones(14,1)];
    B = [meshElement, ones(14,1)];
    
    Tprova = A\B;

    % Applicare la trasformazione all'elemento master
    % Aggiungere una colonna di 1 per ogni punto dell'elemento master per moltiplicare con T
    masterElementAugmented = [masterElement, ones(size(masterElement, 1), 1)];  % Aggiungi colonna di 1

    % Trasformare i punti dell'elemento master utilizzando la matrice T
    transformedElement = (Tprova' * masterElementAugmented')';  % Moltiplicazione matriciale

    % Rimuovere la colonna aggiuntiva (quella di 1 usata per la traslazione)
    transformedElement = transformedElement(:, 1:3);

    % Visualizzare l'elemento trasformato
    disp('Elemento di mesh ottenuto applicando la trasformazione:');
    disp(transformedElement);

    Tprova'

    %% Calcolo la Jacobiana

     % Prealloco una cella per memorizzare le funzioni di forma
    shapeFunction = cell(numNodes,1);
    
    masterElement = [];
    
    searchedString = "pyr";

    if searchedString == "tet"
        masterElement = [0 0 0; 0.5 0 0; 1 0 0; 0 0.5 0; 0.5 0.5 0; 0 1 0; 0 0 0.5;...
                         0.5 0 0.5; 0 0.5 0.5; 0 0 1];
        
        % Funzioni di forma per i nodi della base
        syms xi eta zeta

        shapeFunction{1} = (1-xi-eta-zeta)*(1-(2*xi)-(2*eta)-(2*zeta));
        shapeFunction{2} = (4*xi)*(1-xi-eta-zeta);
        shapeFunction{3} = xi*((2*xi)-1);
        shapeFunction{4} = (4*eta)*(1-xi-eta-zeta);
        shapeFunction{5} = 4*xi*eta;
        shapeFunction{6} = eta*((2*eta)-1);
        shapeFunction{7} = (4*zeta)*(1-xi-eta-zeta);
        shapeFunction{8} = 4*xi*zeta;
        shapeFunction{9} = 4*eta*zeta;
        shapeFunction{10} = zeta*((2*zeta)-1);

    elseif searchedString == "hex"
       masterElement = [0 0 0; 0.5 0 0; 1 0 0; 0 0.5 0; 0.5 0.5 0; 1 0.5 0; 0 1 0; 0.5 1 0; 1 1 0;...
                   0 0 0.5; 0.5 0 0.5; 1 0 0.5; 0 0.5 0.5; 0.5 0.5 0.5; 1 0.5 0.5; 0 1 0.5; 0.5 1 0.5; 1 1 0.5;...
                   0 0 1; 0.5 0 1; 1 0 1; 0 0.5 1; 0.5 0.5 1; 1 0.5 1; 0 1 1; 0.5 1 1; 1 1 1];
        
        syms xi eta zeta
        N = @(xi_i,eta_i,zeta_i)(xi_i*eta_i*zeta_i);
        for i = 1:numNodes
            if masterElement(i,1) == 0
                xi_i = (1-xi)*(1-2*xi);
            elseif masterElement(i,1) == 0.5
                xi_i = 4*xi*(1-xi);
            elseif masterElement(i,1) == 1
                xi_i = xi*(2*xi-1);
            end

            if masterElement(i,2) == 0
                eta_i = (1-eta)*(1-2*eta);
            elseif masterElement(i,2) == 0.5
                eta_i = 4*eta*(1-eta);
            elseif masterElement(i,2) == 1
                eta_i = eta*(2*eta-1);
            end

            if masterElement(i,3) == 0
                zeta_i = (1-zeta)*(1-2*zeta);
            elseif masterElement(i,3) == 0.5
                zeta_i = 4*zeta*(1-zeta);
            elseif masterElement(i,3) == 1
                zeta_i = zeta*(2*zeta-1);
            end

            shapeFunction{i} = N(xi_i, eta_i, zeta_i);
        end

    elseif searchedString == "prism"
        masterElement = [0 0 0; 0.5 0 0; 1 0 0; 0 0.5 0; 0.5 0.5 0; 0 1 0;...
                         0 0 0.5; 0.5 0 0.5; 1 0 0.5; 0 0.5 0.5; 0.5 0.5 0.5; 0 1 0.5;...
                         0 0 1; 0.5 0 1; 1 0 1; 0 0.5 1; 0.5 0.5 1; 0 1 1];
        
        % Funzioni di forma per i nodi della base
        syms xi eta zeta

        shapeFunction{1} = (1-xi-eta)*(1-(2*xi)-(2*eta))*((1-zeta)*(1-(2*zeta)));
        shapeFunction{2} = 4*xi*(1-xi)*((1-zeta)*(1-(2*zeta)));
        shapeFunction{3} = xi*((2*xi)-1)*((1-zeta)*(1-(2*zeta)));
        shapeFunction{4} = (4*eta)*(1-xi-eta)*((1-zeta)*(1-(2*zeta)));
        shapeFunction{5} = 4*xi*eta*((1-zeta)*(1-(2*zeta)));
        shapeFunction{6} = eta*((2*eta)-1)*((1-zeta)*(1-(2*zeta)));
        shapeFunction{7} = (1-xi-eta)*(1-(2*xi)-(2*eta))*((4*zeta)*(1-zeta));
        shapeFunction{8} = (4*xi)*(1-xi-eta)*((4*zeta)*(1-zeta));
        shapeFunction{9} = xi*((2*xi)-1)*((4*zeta)*(1-zeta));
        shapeFunction{10} = (4*eta)*(1-xi-eta)*((4*zeta)*(1-zeta));
        shapeFunction{11} = 4*xi*eta*((4*zeta)*(1-zeta));
        shapeFunction{12} = eta*((2*eta)-1)*((4*zeta)*(1-zeta));
        shapeFunction{13} = (1-xi-eta)*(1-(2*xi)-(2*eta))*(zeta*((2*zeta)-1));
        shapeFunction{14} = (4*xi)*(1-xi-eta)*(zeta*((2*zeta)-1));
        shapeFunction{15} = xi*((2*xi)-1)*(zeta*((2*zeta)-1));
        shapeFunction{16} = (4*eta)*(1-xi-eta)*(zeta*((2*zeta)-1));
        shapeFunction{17} = 4*xi*eta*(zeta*((2*zeta)-1));
        shapeFunction{18} = eta*((2*eta)-1)*(zeta*((2*zeta)-1));

    elseif searchedString == "pyr"
        masterElement = [0 0 0; 0.5 0 0; 1 0 0; 0 0.5 0; 0.5 0.5 0; 1 0.5 0; 0 1 0;...
                         0.5 1 0; 1 1 0; 0.25 0.25 0.5; 0.75 0.25 0.5; 0.25 0.75 0.5; 0.75 0.75 0.5; 0.5 0.5 1];    
        
         % Funzioni di forma per i nodi della base
        syms xi eta zeta

        shapeFunction{1} = (1-xi)*(1-2*xi)*(1-eta)*(1-2*eta)*(1-zeta)*(1-2*zeta);
        shapeFunction{2} =  4*xi*(1-xi)*(1-eta)*(1-2*eta)*(1-zeta)*(1-2*zeta);
        shapeFunction{3} = xi*(2*xi-1)*(1-eta)*(1-2*eta)*(1-zeta)*(1-2*zeta);
        shapeFunction{4} = (1-xi)*(1-2*xi)*4*eta*(1-eta)*(1-zeta)*(1-2*zeta);
        shapeFunction{5} = 4*xi*(1-xi)*4*eta*(1-eta)*(1-zeta)*(1-2*zeta);
        shapeFunction{6} = xi*(2*xi-1)*4*eta*(1-eta)*(1-zeta)*(1-2*zeta);
        shapeFunction{7} = (1-xi)*(1-2*xi)*eta*(2*eta-1)*(1-zeta)*(1-2*zeta);
        shapeFunction{8} = 4*xi*(1-xi)*eta*(2*eta-1)*(1-zeta)*(1-2*zeta);
        shapeFunction{9} = xi*(2*xi-1)*eta*(2*eta-1)*(1-zeta)*(1-2*zeta);
        shapeFunction{10} = 4*(1-xi)*(1-eta)*zeta*(1-2*zeta);
        shapeFunction{11} = 4*xi*(1-eta)*zeta*(1-2*zeta);
        shapeFunction{12} = 4*(1-xi)*eta*zeta*(1-2*zeta);
        shapeFunction{13} = 4*xi*eta*zeta*(1-2*zeta);
        shapeFunction{14} = zeta*(2*zeta-1);

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
    transformedElement = (transformation_matrices{16} * masterElementAugmented')';  % Moltiplicazione matriciale

    % Rimuovere la colonna aggiuntiva (quella di 1 usata per la traslazione)
    transformedElement = transformedElement(:, 1:3);

    % Visualizzare l'elemento trasformato
    disp('Elemento di mesh ottenuto applicando la trasformazione:');
    disp(transformedElement);

end
