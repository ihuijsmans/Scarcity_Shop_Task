function [lastitem, array] = pop(array)
%
% Deletes last item from array and returns last item


lastitem = array(end);
array = array(1:end-1);
end