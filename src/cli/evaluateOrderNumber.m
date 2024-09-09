function elementsOrder = evaluateOrderNumber(model)
    
    modelShapeFunctionsTags = string(model.shape.tags());
    if isempty(modelShapeFunctionsTags)
        elementsOrder = -1;
        return;
    end
    modelShapeFunctionsFirstTag = modelShapeFunctionsTags(1);
    shapeFeatureList = model.shape(modelShapeFunctionsFirstTag).feature();
    firstFeatureString = string(shapeFeatureList(1).toString());
    firstFeatureTag = extractAfter(firstFeatureString, 'Child nodes: ');
    firstFeature = model.shape(modelShapeFunctionsFirstTag).feature(firstFeatureTag);
    elementsOrder = firstFeature.getInt('order');
    
end

