Puppet::Functions.create_function(:get_resources) do
  dispatch :find do
    param 'Type[Resource["class"]]', :cls
  end

  dispatch :return do
    param 'Type[Resource]', :cls
  end

  def find(cls)
    # Get the resource that the reference is referencing
    class_resource = closure_scope.compiler.catalog.resource(cls.to_s)
    # Get all of its children
    children = get_class_child_resources(class_resource)
    # If the class has a child that is a class, recurse
    children.delete_if { |r| r.exported? }
  end

  def return(resource)
    resource
  end

  # We need to recursively get resources so that we obey the rules of
  # containment as expected
  def get_class_child_resources(class_resource)
    resources = closure_scope.compiler.catalog.direct_dependents_of(class_resource)
    resources.map! do |resource|
      if resource.class?
        get_class_child_resources(resource)
      else
        resource
      end
    end
    resources.flatten
  end
end
