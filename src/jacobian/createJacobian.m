function [tableJacobian] = createJacobian(incidenceMatrices,tableShapeFunctions)
    %CREATEJACOBIAN calcola la matrice jacobiana, il suo determinante e
    %l'inversa della jacobiana con relativo determinante
    
    % Tabella mesh-nodi
    mesh_elements = incidenceMatrices.arrayNodesElements;
    
    % Tabella nodi-coordinate 
    coord_nodes = incidenceMatrices.arrayNodalCoordinates;
    
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

    shapeFunctions = table2array(tableShapeFunctions);
    
    for i = 1 : size(shapeFunctions,1)
        shapeFunctions(i) = evalin(symengine,shapeFunctions(i));
    end

    dN_dxi = sym(zeros(1,numNodes));
    dN_deta = sym(zeros(1,numNodes));
    dN_dzeta = sym(zeros(1,numNodes));

    % Calcolo le derivate per costruire la jacobiana
    for i = 1:size(shapeFunctions)
        dN_dxi(1,i) = diff(shapeFunctions(i),xi);
        dN_deta(1,i) = diff(shapeFunction(i),eta);
        dN_dzeta(1,i) = diff(shapeFunction(i),zeta);
    end

    % Definisco le coordinate locali
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

end

