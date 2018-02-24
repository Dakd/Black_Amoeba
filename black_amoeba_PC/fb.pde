 public void fastBlur(PImage pimage, int i)
    {
        if(i < 1)
            return;
        int j = pimage.width;
        int k = pimage.height;
        int l = j - 1;
        int i1 = k - 1;
        int j1 = j * k;
        int k1 = i + i + 1;
        int ai[] = new int[j1];
        int ai1[] = new int[j1];
        int ai2[] = new int[j1];
        int ai3[] = new int[j1];
        int ai4[] = new int[max(j, k)];
        int ai5[] = new int[max(j, k)];
        int ai6[] = pimage.pixels;
        int ai7[] = new int[256 * k1];
        for(int l4 = 0; l4 < 256 * k1; l4++)
            ai7[l4] = l4 / k1;

        int i7;
        int l7 = i7 = 0;
        for(int j4 = 0; j4 < k; j4++)
        {
            int j2;
            int l2;
            int j3;
            int l1 = j2 = l2 = j3 = 0;
            for(int i5 = -i; i5 <= i; i5++)
            {
                int k5 = ai6[i7 + min(l, max(i5, 0))];
                l1 += k5 >> 24 & 0xff;
                j2 += (k5 & 0xff0000) >> 16;
                l2 += (k5 & 0xff00) >> 8;
                j3 += k5 & 0xff;
            }

            for(int l3 = 0; l3 < j; l3++)
            {
                ai[i7] = ai7[l1];
                ai1[i7] = ai7[j2];
                ai2[i7] = ai7[l2];
                ai3[i7] = ai7[j3];
                if(j4 == 0)
                {
                    ai4[l3] = min(l3 + i + 1, l);
                    ai5[l3] = max(l3 - i, 0);
                }
                int l5 = ai6[l7 + ai4[l3]];
                int j6 = ai6[l7 + ai5[l3]];
                l1 += (l5 >> 24 & 0xff) - (j6 >> 24 & 0xff);
                j2 += (l5 & 0xff0000) - (j6 & 0xff0000) >> 16;
                l2 += (l5 & 0xff00) - (j6 & 0xff00) >> 8;
                j3 += (l5 & 0xff) - (j6 & 0xff);
                i7++;
            }

            l7 += j;
        }

        for(int i4 = 0; i4 < j; i4++)
        {
            int k2;
            int i3;
            int k3;
            int i2 = k2 = i3 = k3 = 0;
            int l6 = -i * j;
            for(int j5 = -i; j5 <= i; j5++)
            {
                int j7 = max(0, l6) + i4;
                i2 += ai[j7];
                k2 += ai1[j7];
                i3 += ai2[j7];
                k3 += ai3[j7];
                l6 += j;
            }

            int k7 = i4;
            for(int k4 = 0; k4 < k; k4++)
            {
                ai6[k7] = ai7[i2] << 24 | ai7[k2] << 16 | ai7[i3] << 8 | ai7[k3];
                if(i4 == 0)
                {
                    ai4[k4] = min(k4 + i + 1, i1) * j;
                    ai5[k4] = max(k4 - i, 0) * j;
                }
                int i6 = i4 + ai4[k4];
                int k6 = i4 + ai5[k4];
                i2 += ai[i6] - ai[k6];
                k2 += ai1[i6] - ai1[k6];
                i3 += ai2[i6] - ai2[k6];
                k3 += ai3[i6] - ai3[k6];
                k7 += j;
            }

        }

    }
