function number = select_round(value, roundvalue)
%Rounds numbers to a preset rounding value. Examples:
% select_round(2.19, 0.05) = 2.20
% select_round(316, 10) = 320
% select_round(25.09, 0.20) = 25.00

round = value/roundvalue;
integer = floor(round);
decimals = round-integer;
if decimals < 0.5
    number = integer*roundvalue;
else
    number = (integer+1)*roundvalue;

end
