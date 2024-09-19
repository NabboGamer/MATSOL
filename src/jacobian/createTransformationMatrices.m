function transformationMatrices = createTransformationMatrices(incidenceMatrices, tableJacobian)
    %CREATETRANSFORMATIONMATRICES genera la matrice di trasformazione per passare dalle coordinate locali (sistema di riferimento dell'elemento master unitario) alle coordinate globali (sistema di riferimento dell'elemento di mesh)
    
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

    % Calcolo la matrice di trasformazione
    transformation_matrices = cell(size(mesh_elements,1),1);

    JacobianInfo = table2array(tableJacobian);

    Jacobian = JacobianInfo(:,1);

    for i = 1 : numElements
        refCoord = [coord_mesh{i}(1,1) coord_mesh{i}(1,2) coord_mesh{i}(1,3)];
        T = [Jacobian{i}, refCoord'; 0 0 0 1];
        T = round(T,10);
        transformation_matrices{i} = T;
    end
    
    nodeLabels = strcat('e_', string(1:size(coord_mesh_table, 2)));
    transformationMatrices = cell2table(transformation_matrices','VariableNames', nodeLabels, "RowNames","transformation Matrices");
    
    %Per effettuare la trasformazione di coordinate bisogna passare alle
    %rappresentazioni omogenee (aggiunta di una riga/colonna (dipende dalla rappresentazione utilizzata,
    % contenente 0 per indicare un vettore, 1 per indicare un punto).

    %L'elemento trasformato (ovvero nelle coordinate globali) sarà dato
    %dalla trasposizione del prodotto tra la matrice di trasformazione e le
    %coordinate locali (insieme di coordinate) che si vogliono trasformare trasposte

    %Di seguito un esempio per trasformare l'elemento master nel primo
    %elemento della mesh

    % Aggiungere una colonna di 1 per ogni punto dell'elemento master
    % (rappresentazione omogenea)
    %masterElementAugmented = [masterElement, ones(size(masterElement, 1), 1)]; 

    % Trasformare le coordinate dell'elemento master utilizzando la matrice
    % di trasformazione
    %transformedElement = (transformation_matrices{1} * masterElementAugmented')';

    % Rimuovere la colonna aggiuntiva per ritornare alla rappresentazione
    % canonica
    %transformedElement = transformedElement(:, 1:3);

    % Visualizzare l'elemento trasformato
    %disp('Elemento di mesh ottenuto applicando la trasformazione:');
    %disp(transformedElement);


end

