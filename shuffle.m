function [shuffled_array] = shuffle(array)
%
% Randomizes order of array
% shuffle([1, 2, 3, 4]) = [3, 2, 4, 1]


shuffled_array = array(randperm(length(array)));

end