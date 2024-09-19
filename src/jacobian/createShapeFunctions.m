function tableShapeFunctions = createShapeFunctions(model, selectedComponentGeometryTag, geometryTagPos, meshdata, meshdataTypeList, elementsType, elementsOrder, flagsStruct)
    %CREATESHAPEFUNCTIONS si occupa di fornire le funzioni di forma nodali per l'elemento di interesse 
    
    flagsStruct.arrayNodesFaces.calculate = true;

    incidenceMatrices = createIncidenceMatricesForCLI(model,...
                                                      selectedComponentGeometryTag,...
                                                      geometryTagPos,...
                                                      meshdata,...
                                                      meshdataTypeList,...
                                                      elementsType,...
                                                      elementsOrder,...
                                                      flagsStruct,...
                                                      '../../saved_matrices/incidenceMatricesPyr.json',...
                                                      false);
    
    % Tabella mesh-nodi
    mesh_elements = incidenceMatrices.arrayNodesElements;
    
    % Numero di nodi per elemento di mesh
    numNodes = size(mesh_elements, 2);

    % Prealloco una cella per memorizzare le funzioni di forma
    shapeFunction = cell(numNodes,1);

    if elementsOrder == 1

        if elementsType == "hex"

            % Definizione delle coordinate locali (dell'elemento master)
            masterElement = [ 0 0 0; 1 0 0; 0 1 0; 1 1 0; 0 0 1; 1 0 1; 0 1 1; 1 1 1];
    
            % Calcolo le funzioni di forma per un elemento esaedrico lineare
            syms xi eta zeta
            N = @(xi_i, eta_i, zeta_i)(...
                (((1-xi)^(1-xi_i)) * xi^xi_i) * (((1-eta)^(1-eta_i)) * eta^eta_i) * (((1-zeta)^(1-zeta_i)) * zeta^zeta_i));

        elseif elementsType == "tet"
            masterElement = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
    
            syms xi eta zeta
            N = @(xi_i, eta_i, zeta_i)(...
                (1-xi-eta-zeta)+xi_i*(2*xi+eta+zeta-1)+eta_i*(xi+2*eta+zeta-1)+zeta_i*(xi+eta+2*zeta-1));
    
        elseif elementsType == "prism"

            masterElement = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 0 1; 0 1 1];
            
            % Calcolo le funzioni di forma per un elemento esaedrico lineare
            syms xi eta zeta
            N = @(xi_i, eta_i, zeta_i)(...
                ((1-xi-eta)^(1-xi_i-eta_i))*(xi^xi_i)*(eta^eta_i)*((1-zeta)^(1-zeta_i))*(zeta^zeta_i));
    
        elseif elementsType == "pyr"
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

    else
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

    end
    
    nodeLabels = strcat('n_', string(1:size(shapeFunction,1)));
    tableShapeFunctions = cell2table(shapeFunctions,'VariableNames', 'shape_fcn','RowNames', nodeLabels);
    
end

