import numpy as np
import math
import csv

###### BASIC compressor
## calculate 1bit mult per each partial sum position
def partial_bit(x, xl, y, yl, loc=0):
    return (((x >> xl) & (y >> yl) & 1) << loc)

## sum of half adder,, &1 is for acquiring 1bit output
def sha(x, y):
    return ((x ^ y) & 1)

## carry out of half adder
def cha(x, y):
    return ((x & y) & 1)

## sum of full adder
def sfa(x, y, z):
    return ((x ^ y ^ z) & 1)

## carry out of full adder,, same as 
def cfa(x, y, z):
    return ((x & y) | (x & z) | (y & z)) & 1

## exact version of 4:2 compressor == 5 to 3 compressor
def exact_4to2_compressor(x1, x2, x3, x4, Tin):
    # pre-process
    Tin = Tin & 1
    x1  = x1  & 1
    x2  = x2  & 1
    x3  = x3  & 1
    x4  = x4  & 1

    # real calc
    Tout = cfa(x4, x3, x2)
    temp = sfa(x4, x3, x2)
    carry_bit = cfa(temp, x1, Tin)
    sum_bit   = sfa(temp, x1, Tin)

    return sum_bit, carry_bit, Tout


###### suggested compressor
def Ahma4to2(a, b, c, d):
    x1 = a & 1
    x2 = b & 1
    x3 = c & 1
    x4 = d & 1

    temp1 = (~(x1 | x2)) & 1
    temp2 = (~(x3 | x4)) & 1

    carry_bit = (~(temp1 | temp2)) & 1
    sum_bit   = (~(temp1 & temp2)) & 1

    return sum_bit, carry_bit

def Ansari4to2(a, b, c, d):
    x1 = a & 1
    x2 = b & 1
    x3 = c & 1
    x4 = d & 1

    carry_bit = (~((~(x1 & x2)) & (~(x3 & x4)))) & 1
    sum_bit   = (~((~(x1 | x2)) & (~(x3 | x4)))) & 1
    
    return sum_bit, carry_bit


# x should be activation (always positive), y should be weights (positive or negative)
# all input are 8bit
# low bit: use inaccurate 4:2 compressor, high bit: use accurate 4:2 compressor
def proposed_approx_mul(x, y):
    ### define first partial sum & final output list
    ab = np.zeros((8, 8), dtype=int)
    o  = np.zeros(16, dtype=int)

    ####################################
    ### stage0: generate partial sum ###
    ####################################
    x_neg = ((~x) + 1) & 0x1FF   # x's 9bit 2's complement (1bit sign, 8bit data)

    for i in range(8):
        for j in range(8):
            if j == 0:  # sign bit row
                ab[i, j] = partial_bit(x_neg, 7 - i, y, 7 - j, 0)
            else:
                ab[i, j] = partial_bit(x, 7 - i, y, 7 - j, 0)
    msb_ = partial_bit(x_neg, 8, y, 7, 0)

    """
    RESULT: 
                                  |                                                     X(8bit)
                                  |                                                   * Y(8bit)
             ---------------------------------------------------------------------------------
                                  |             [0,7] [1,7] [2,7] [3,7] [4,7] [5,7] [6,7] [7,7] 
                                  |       [0,6] [1,6] [2,6] [3,6] [4,6] [5,6] [6,6] [7,6]  
                                  | [0,5] [1,5] [2,5] [3,5] [4,5] [5,5] [6,5] [7,5]  
                             [0,4]| [1,4] [2,4] [3,4] [4,4] [5,4] [6,4] [7,4]  
                       [0,3] [1,3]| [2,3] [3,3] [4,3] [5,3] [6,3] [7,3]
                 [0,2] [1,2] [2,2]| [3,2] [4,2] [5,2] [6,2] [7,2]
           [0,1] [1,1] [2,1] [3,1]| [4,1] [5,1] [6,1] [7,1]
msb_ [0,0] [1,0] [2,0] [3,0] [4,0]| [5,0] [6,0] [7,0] <- 2's comp of X,, need 9bit to indicate sign bit
       accurate computation             inaccurate computation
    """

    ###############
    ### Stage 1 ###
    ###############
    c_h0_1s = cha(ab[3,7], ab[4,6])
    s_h0_1s = sha(ab[3,7], ab[4,6])

    c_h1_1s = cha(ab[5,3], ab[6,2])
    s_h1_1s = sha(ab[5,3], ab[6,2])

    c_h2_1s = cha(ab[4,1], ab[5,0])
    s_h2_1s = sha(ab[4,1], ab[5,0])

    # c_h3_1s = cha(ab[0,3], ab[1,2])
    # s_h3_1s = sha(ab[0,3], ab[1,2])

    c_f0_1s = cfa(ab[4,2], ab[5,1], ab[6,0])
    s_f0_1s = sfa(ab[4,2], ab[5,1], ab[6,0])
    
    s_m0_1s, c_m0_1s = Ahma4to2(ab[2,7], ab[3,6], ab[4,5], ab[5,4])
    s_m1_1s, c_m1_1s = Ahma4to2(ab[1,7], ab[2,6], ab[3,5], ab[4,4])
    s_m2_1s, c_m2_1s = Ahma4to2(ab[0,7], ab[1,6], ab[2,5], ab[3,4])
    s_m3_1s, c_m3_1s = Ahma4to2(ab[4,3], ab[5,2], ab[6,1], ab[7,0])
    s_m4_1s, c_m4_1s = Ahma4to2(ab[0,6], ab[1,5], ab[2,4], ab[3,3])
    s_m5_1s, c_m5_1s = Ahma4to2(ab[0,5], ab[1,4], ab[2,3], ab[3,2])
    # s_m6_1s, c_m6_1s = Ahma4to2(ab[0,4], ab[1,3], ab[2,2], ab[3,1])

    # for accurate computation..
    s_a0_1s, c_a0_1s, t_a0_1s = exact_4to2_compressor(ab[0,4], ab[1,3], ab[2,2], ab[3,1], 0)
    c_a1_1s = cfa(ab[0,3], ab[1,2], t_a0_1s)
    s_a1_1s = sfa(ab[0,3], ab[1,2], t_a0_1s)

    
    ###############
    ### Stage 2 ###
    ###############
    c_h4_2s = cha(ab[5,7], ab[6,6])
    s_h4_2s = sha(ab[5,7], ab[6,6])

    # c_h5_2s = cha(ab[1,0], ab[0,1])
    # s_h5_2s = sha(ab[1,0], ab[0,1])

    s_m7_2s,  c_m7_2s  =   Ahma4to2(ab[4,7], ab[5,6], ab[6,5], ab[7,4])
    s_m8_2s,  c_m8_2s  =   Ahma4to2(ab[5,5], ab[6,4], ab[7,3], s_h0_1s)
    s_m9_2s,  c_m9_2s  = Ansari4to2(ab[6,3], c_h0_1s, ab[7,2], s_m0_1s)
    s_m10_2s, c_m10_2s = Ansari4to2(ab[7,1], c_m0_1s, s_m1_1s, s_h1_1s)
    s_m11_2s, c_m11_2s = Ansari4to2(c_m1_1s, c_h1_1s, s_m2_1s, s_m3_1s)
    s_m12_2s, c_m12_2s = Ansari4to2(c_m2_1s, c_m3_1s, s_m4_1s, s_f0_1s)
    s_m13_2s, c_m13_2s = Ansari4to2(c_m4_1s, c_f0_1s, s_m5_1s, s_h2_1s)
    # s_m14_2s, c_m14_2s = Ansari4to2(c_m5_1s, c_h2_1s, ab[4,0], s_m6_1s)
    # s_m15_2s, c_m15_2s =   Ahma4to2(ab[2,1], ab[3,0], c_m6_1s, s_h3_1s)
    # s_m16_2s, c_m16_2s =   Ahma4to2(ab[0,2], ab[1,1], ab[2,0], c_h3_1s)

    # for accurate computation..
    s_a2_2s, c_a2_2s, t_a2_2s = exact_4to2_compressor(c_m5_1s, c_h2_1s, ab[4,0], s_a0_1s, 0)
    s_a3_2s, c_a3_2s, t_a3_2s = exact_4to2_compressor(ab[2,1], ab[3,0], s_a1_1s, c_a0_1s, t_a2_2s)
    s_a4_2s, c_a4_2s, t_a4_2s = exact_4to2_compressor(ab[0,2], ab[1,1], ab[2,0], c_a1_1s, t_a3_2s)
    s_a5_2s = sfa(ab[1,0], ab[0,1], t_a4_2s)
    c_a5_2s = cfa(ab[1,0], ab[0,1], t_a4_2s)


    ####################################
    ### Stage 3 (final accumulation) ###
    ####################################
    o[0] = ab[7,7]

    o[1]    = sha(ab[6,7], ab[7,6])
    c_h6_3s = cha(ab[6,7], ab[7,6])

    o[2]    = sfa(ab[7,5], s_h4_2s, c_h6_3s)
    c_f1_3s = cfa(ab[7,5], s_h4_2s, c_h6_3s)

    o[3]    = sfa(s_m7_2s, c_h4_2s, c_f1_3s)
    c_f2_3s = cfa(s_m7_2s, c_h4_2s, c_f1_3s)

    o[4]    = sfa(s_m8_2s, c_m7_2s, c_f2_3s)
    c_f3_3s = cfa(s_m8_2s, c_m7_2s, c_f2_3s)

    o[5]    = sfa(s_m9_2s, c_m8_2s, c_f3_3s)
    c_f4_3s = cfa(s_m9_2s, c_m8_2s, c_f3_3s)

    o[6]    = sfa(s_m10_2s, c_m9_2s, c_f4_3s)
    c_f5_3s = cfa(s_m10_2s, c_m9_2s, c_f4_3s)

    o[7]    = sfa(s_m11_2s, c_m10_2s, c_f5_3s)
    c_f6_3s = cfa(s_m11_2s, c_m10_2s, c_f5_3s)

    o[8]    = sfa(s_m12_2s, c_m11_2s, c_f6_3s)
    c_f7_3s = cfa(s_m12_2s, c_m11_2s, c_f6_3s)

    o[9]    = sfa(s_m13_2s, c_m12_2s, c_f7_3s)
    c_f8_3s = cfa(s_m13_2s, c_m12_2s, c_f7_3s)

    ## part for accurate computation..
    o[10]   = sfa(s_a2_2s, c_m13_2s, c_f8_3s)
    c_f9_3s = cfa(s_a2_2s, c_m13_2s, c_f8_3s)

    o[11]   = sfa(s_a3_2s, c_a2_2s, c_f9_3s)
    c_f10_3s= cfa(s_a3_2s, c_a2_2s, c_f9_3s)

    o[12]   = sfa(s_a4_2s, c_a3_2s, c_f10_3s)
    c_f11_3s= cfa(s_a4_2s, c_a3_2s, c_f10_3s)

    o[13]   = sfa(s_a5_2s, c_a4_2s, c_f11_3s)
    c_f12_3s= cfa(s_a5_2s, c_a4_2s, c_f11_3s)

    o[14]   = sfa(ab[0,0], c_a5_2s, c_f12_3s)
    c_f13_3s= cfa(ab[0,0], c_a5_2s, c_f12_3s)

    o[15]   = sha(msb_, c_f13_3s)


    ###################
    ### pack result ###
    ###################
    out = 0
    for i in range(15):
        out += (o[i] << i)
    if o[15] == 1:
        out -= (1 << 15)

    return int(out)