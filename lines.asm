// routine to count the number of lines in a program
// created by mikroman on Friday the 13th of June, 2025
//
// load this program FIRST then
// NEW the BASIC area to reset storage variables
// load the BASIC program
// call the routine with SYS49152 to see the result

.label LINPRT = $bdcd         // KERNAL print unsigned integer routine
.const StartAt = 1            // start at one. second link is the start

// zero page labels

* = $002b "storage" virtual   // BASIC ROM label
TXTTAB:                       // start of BASIC

* = $00fb "storage" virtual   // program storage for links and counter

linkLB:                       // line link storage
*=*+1
linkHB:
*=*+1

totlinesLB:                   // number of lines counter
*=*+1
totlinesHB:

*=$c000 "main"                // set to load into 12x2096 = 49152 decimal

start:
          ldy #StartAt        // start at 1
          sty totlinesLB      // reset line counter
          lda (TXTTAB),y      // second byte of program is the link HB
          sta linkHB          // save HB of link for zeropage operations
          dey
          sty totlinesHB      // initialise line counter HB to zero
          lda (TXTTAB),y      // get the first link LB
          beq search_done + 1 // 0=no prg loaded
          sta linkLB          // save LB of link

get_next_link:                // y=0 on enter

          lda (linkLB),y      // get link LB
          pha                 // save LB
          iny                 // y=1
          lda (linkLB),y      // get link HB
          beq search_done     // 0 signals END of program
          dey                 // else we reset y to zero
          sta linkHB          // save new link HB
          pla                 // recall LB
          sta linkLB          // save new link LB
          inc totlinesLB      // bump line counter by one
          bne get_next_link   // if less than 256 then loop
          inc totlinesHB      // else we increase the counter HB
          bne get_next_link   // jmp always - no lines beyond 63999

search_done:

          pla                 // resolve the stack
          lda totlinesHB      // get high and
          ldx totlinesLB      // low byte values
          jmp LINPRT          //  to print our result