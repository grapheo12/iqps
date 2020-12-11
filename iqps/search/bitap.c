#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <stdio.h>

int bitap_fuzzy_bitwise_search(const char *text, const char *pattern, int k)
{
 int result = -1;
 int m = strlen(pattern);
 unsigned long *R;
 unsigned long pattern_mask[CHAR_MAX+1];
 int i, d;

 if (pattern[0] == '\0') return -1;
 if (m > 31) return -1;

 /* Initialize the bit array R */
 R = malloc((k+1) * sizeof *R);
 for (i=0; i <= k; ++i)
     R[i] = 1;

 /* Initialize the pattern bitmasks */
 for (i=0; i <= CHAR_MAX; ++i)
     pattern_mask[i] = 0;
 for (i=0; i < m; ++i)
     pattern_mask[pattern[i]] |= (1UL << i);

 for (i=0; text[i] != '\0'; ++i) {
     /* Update the bit arrays */
     unsigned long old_Rd = 0;
     unsigned long old_Rd_next = 0;

     for (d=0; d <= k; ++d) {
         unsigned long Rins = old_Rd | ((R[d] & pattern_mask[text[i]]) << 1);
         unsigned long Rdel = (old_Rd_next | (R[d] & pattern_mask[text[i]])) << 1;
         unsigned long Rsub = (old_Rd | (R[d] & pattern_mask[text[i]])) << 1;
         old_Rd = R[d];
         R[d] = Rins | Rdel | Rsub | 1;
         old_Rd_next = R[d];
     }

     if (0 < (R[k] & (1UL << m))) {
         result = i;
         break;
     }
 }

 free(R);
 return result;
}

// int main() {
//     char text[200];
//     scanf("%[^\n]%*c", text);
//     char pattern[20];
//     scanf("%[^\n]%*c", pattern);
//     printf("%d", bitap_fuzzy_bitwise_search(text, pattern, 2));
// }