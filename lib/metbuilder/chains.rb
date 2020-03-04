# encoding: UTF-8

$chains={
			   '2:0' => ['acetyl','C(=O)C'],
			   '3:0' => ['propionyl','C(=O)CC',],
			   '4:0' => ['butyryl','C(=O)CCC'],
			   '5:0' => ['valeryl','C(=O)CCCC'],
			   '6:0' => ['hexanoyl','C(=O)CCCCC'],
			   '7:0' => ['heptanoyl','C(=O)CCCCCC'],
			   '8:0' => ['octanoyl','C(=O)CCCCCCC'],
			   '9:0' => ['nonanoyl','C(=O)CCCCCCCC'],
			   '10:0' => ['decanoyl','C(=O)CCCCCCCCC'],
			   '11:0' => ['undecanoyl','C(=O)CCCCCCCCCC'],
			   '12:0' => ['dodecanoyl','C(=O)CCCCCCCCCCC'],
			   '13:0' => ['tridecanoyl','C(=O)CCCCCCCCCCCC'],
			   '14:0' => ['tetradecanoyl','C(=O)CCCCCCCCCCCCC'],
			   'P-14:0' => ['(1Z-tetradecanoyl)','C=CCCCCCCCCCCCC'],
			   '14:1n5' => ['(5-tetradecyl)','C(=O)CCCC=CCCCCCCCC'],
			   #'O-14:0' => ['tetradecyl','CCCCCCCCCCCCCC'],
			   'o-14:0' => ['tetradecyl','CCCCCCCCCCCCCC'],
			   '14:1(9Z)' => ['(9Z-tetradecenoyl)','C(=O)CCCCCCC\C=C/CCCC'],
			   '14:1(11Z)' => ['(11Z-tetradecenoyl)','C(=O)CCCCCCCCC\C=C/CC'],
			   '15:0' => ['pentadecanoyl','C(=O)CCCCCCCCCCCCCC'],
			   '15:1(9Z)' => ['(9Z-pentadecenoyl)','C(=O)CCCCCCC\C=C/CCCCC'],
			   '15:1(11Z)' => ['(11Z-pentadecenoyl)','C(=O)CCCCCCCCC\C=C/CCC'],
			   '16:0' => ['hexadecanoyl','C(=O)CCCCCCCCCCCCCCC'],
			   '16:0e' => ['hexadecyl','CCCCCCCCCCCCCCCC'],
			   'o-16:0' => ['hexadecyl','CCCCCCCCCCCCCCCC'],
			   '16:0p' => ['(1Z-hexadecenyl)','C=CCCCCCCCCCCCCCC'],
			   'P-16:0' => ['(1Z-hexadecenyl)','C=CCCCCCCCCCCCCCC'],
			   'dm16:0' => ['(1Z-hexadecenyl)','C=CCCCCCCCCCCCCCC'],
			   'P-16:0e' => ['(1Z-hexadecenyl)','C=CCCCCCCCCCCCCCC'],
			   'dm16:0e' => ['(1Z-hexadecenyl)','C=CCCCCCCCCCCCCCC'],
			   'O-16:1(1Z)' => ['(1Z-hexadecenyl)','C=CCCCCCCCCCCCCCC'],
			   'O-16:1(9Z)' => ['(9Z-hexadecenyl)','CCCCCCCC\C=C/CCCCCC'],
			   '16:1(7Z)' => ['(9Z-hexadecenoyl)','C(=O)CCCCCCC\C=C/CCCCCC'],
			   '16:1n7' =>['(7-hexadecenoyl)','C(=O)CCCCCC=CCCCCCCCC'],
			   '16:1(9Z)' => ['(9Z-hexadecenoyl)','C(=O)CCCCCCC\C=C/CCCCCC'],
			   '16:1(8Z)' => ['(8Z-hexadecenoyl)','C(=O)CCCCCC\C=C/CCCCCCC'],
			   '16:1(11Z)' => ['(11Z-hexadecenoyl)','C(=O)CCCCCCCCC\C=C/CCCC'],
			   '16:2(9Z,11Z)' => ['(9Z,11Z-hexadecenoyl)','C(=O)CCCCCCC\C=C/\C=C/CCCC'],
         '16:2(9Z,12Z)' => ['(9Z,12Z-hexadecenoyl)','C(=O)CCCCCCC\C=C/C\C=C/CCC'],
			   '16:3(6Z,9Z,12Z)' => ['(6Z,9Z,12Z-hexadecatrienoyl)','C(=O)CCCC\C=C/C\C=C/C\C=C/CCC'],
			   'o-17:0' => ['heptadecyl','CCCCCCCCCCCCCCCCC'],
			   '17:0' => ['heptadecanoyl','C(=O)CCCCCCCCCCCCCCCC'],
			   '17:1(9Z)' => ['(9Z-heptadecenoyl)','C(=O)CCCCCCC\C=C/CCCCCCC'],
			   '17:1(10Z)' => ['(10Z-heptadecenoyl)','C(=O)CCCCCCCC\C=C/CCCCCC'],
			   '17:1(11Z)' => ['(11Z-heptadecenoyl)','C(=O)CCCCCCCCC\C=C/CCCCC'],
			   '17:2(9Z,12Z)' => ['(9Z,12Z-heptadecadienoyl)','C(=O)CCCCCCC\C=C/C\C=C/CCCC'],
			   '18:0' => ['octadecanoyl','C(=O)CCCCCCCCCCCCCCCCC'],
			   '18:0e' => ['octadecyl','CCCCCCCCCCCCCCCCCC'],
			   #'O-18:0' => ['octadecyl','CCCCCCCCCCCCCCCCCC'],
			   'o-18:0' => ['octadecyl','CCCCCCCCCCCCCCCCCC'],
			   'dm18:0' => ['octadecyl','C=CCCCCCCCCCCCCCCCC'],
			   '18:0p' => ['(1Z-octadecenyl)','C=CCCCCCCCCCCCCCCCC'],
			   'P-18:0' => ['(1Z-octadecenyl)','C=CCCCCCCCCCCCCCCCC'],
			   'O-18:1(1Z)' => ['(1Z-octadecenyl)','C=CCCCCCCCCCCCCCCCC'],  #smiles corrected
			   'dm18:1n9' => ['(1,9-octadecadienyl)','C=CCCCCCCC=CCCCCCCCC'],
			   # original 'dm18:1(9Z)' => ['(1,9-octadecadienyl)','C=CCCCCCCC=CCCCCCC'],
			   # Fixed:
			   'dm18:1(9Z)' => ['(1,9-octadecadienyl)','C=CCCCCCC\C=C/CCCCCCCC'],
			   'o-18:1n9' => ['(9Z-octadecadienyl)','CCCCCCCC\C=C/CCCCCCCC'],   #smiles corrected
			   'o-18:1(9Z)' => ['(9Z-octadecadienyl)','CCCCCCCC\C=C/CCCCCCCC'],  #smiles corrected
			   'o-18:1(11Z)' => ['(11Z-octadecadienyl)','CCCCCCCCCC\C=C/CCCCCC'],
			   'P-18:1(9Z)' => ['(1Z,9Z-octadecadienyl)','C=CCCCCCC\C=C/CCCCCCCC'],
			   '18:1(4E)' => ['(4E-octadecenoyl)','C(=O)CC/C=C/CCCCCCCCCCCCC'],
			   '18:1(6Z)' => ['(6Z-octadecenoyl)','C(=O)CCCC\C=C/CCCCCCCCCCC'],
			   '18:1n9' => ['(9Z-octadecenoyl)','C(=O)CCCCCCC\C=C/CCCCCCCC'],
			   '18:1(7Z)' => ['(7Z-octadecenoyl)','C(=O)CCCCC\C=C/CCCCCCCCCC'],
			   '18:1(9Z)' => ['(9Z-octadecenoyl)','C(=O)CCCCCCC\C=C/CCCCCCCC'],
			   '18:1(9E)' => ['(9E-octadecenoyl)','C(=O)CCCCCCC/C=C/CCCCCCCC'],
			   '18:1(11E)' => ['(11E-octadecenoyl)','C(=O)CCCCCCCCC/C=C/CCCCCC'],
			   '18:1n7' => ['(11Z-octadecenoyl)','C(=O)CCCCCCCCC\C=C/CCCCCC'],
			   '18:1(11Z)' => ['(11Z-octadecenoyl)','C(=O)CCCCCCCCC\C=C/CCCCCC'],
			   'dm18:1(11Z)' => ['(1,11-octadecadienyl)','C=CCCCCCCCC\C=C/CCCCCC'],
			   'P-18:1(11Z)' => ['(1Z,11Z-octadecadienyl)','C=CCCCCCCCC\C=C/CCCCCC'],
			   '18:1(13Z)' => ['(13Z-octadecenoyl)','C(=O)CCCCCCCCCCC\C=C/CCCC'],
			   '18:1(17Z)' => ['(13Z-octadecenoyl)','C(=O)CCCCCCCCCCCCCCC\C=C/'],
			   '18:1(8Z)' => ['(13Z-octadecenoyl)','C(=O)CCCCCC\C=C/CCCCCCCCC'],
			   '18:2(2E,4E)' => ['(2E,4E-octadecadienoyl)','C(=O)/C=C/C=C/CCCCCCCCCCCCC'],
			   '18:2(6Z,9Z)' => ['(6Z,9Z-octadecadienoyl)','C(=O)CCCC\C=C/C\C=C/CCCCCCCC'],
			   '18:2(9E,11E)' => ['(9E,11E-octadecadienoyl)','C(=O)CCCCCCC/C=C/C=C/CCCCCC'],
			   '18:2(9Z,11Z)' => ['(9Z,11Z-octadecadienoyl)','C(=O)CCCCCCC/C=C\C=C/CCCCCC'],
			   '18:2(9Z,11E)' => ['(9Z,11E-octadecadienoyl)','C(=O)CCCCCCC\C=C/C=C/CCCCCC'],
			   '18:2n6' => ['(9Z,12Z-octadecadienoyl)','C(=O)CCCCCCC/C=C\C\C=C/CCCCC'],   #smiles corrected
			   '18:2(9Z,12Z)' => ['(9Z,12Z-octadecadienoyl)','C(=O)CCCCCCC/C=C\C\C=C/CCCCC'],
			   'o-18:2n6' => ['(9Z,12Z-octadecadienyl)','CCCCCCCC/C=C\C\C=C/CCCCC'],  #smiles corrected
			   'o-18:2(9Z,12Z)' => ['(9Z,12Z-octadecadienyl)','CCCCCCCC/C=C\C\C=C/CCCCC'],  #smiles corrected
			   '18:2(9E,12E)' => ['(9E,12E-octadecadienoyl)','C(=O)CCCCCCC/C=C/C/C=C/CCCCC'],    #smiles corrected
			   '18:3n6' => ['(6Z,9Z,12Z-octadecatrienoyl)','C(=O)CCCC\C=C/C\C=C/C\C=C/CCCCC'],
			   '18:3(6Z,9Z,12Z)' => ['(6Z,9Z,12Z-octadecatrienoyl)','C(=O)CCCC\C=C/C\C=C/C\C=C/CCCCC'],
			   '18:3(8E,10E,12Z)' => ['(8E,10E,12Z-octadecatrienoyl)','C(=O)CCCCCC/C=C/C=C/C=C/CCCCC'],
			   '18:3n3' => ['(9Z,12Z,15Z-octadecatrienoyl)','C(=O)CCCCCCC\C=C/C\C=C/C\C=C/CC'],
			   '18:3(9Z,12Z,15Z)' => ['(9Z,12Z,15Z-octadecatrienoyl)','C(=O)CCCCCCC\C=C/C\C=C/C\C=C/CC'],
			   '18:4n3' => ['(6Z,9Z,12Z,15Z-octadecatetraenoyl)','C(=O)CCCC\C=C/C\C=C/C\C=C/C\C=C/CC'],
			   '18:4(6Z,9Z,12Z,15Z)' => ['(6Z,9Z,12Z,15Z-octadecatetraenoyl)','C(=O)CCCC\C=C/C\C=C/C\C=C/C\C=C/CC'],
			   '18:4(9E,11E,13E,15E)' => ['(9E,11E,13E,15E-octadecatetraenoyl)','C(=O)CCCCCCC/C=C/C=C/C=C/C=C/CC'],
			   '19:0' => ['nonadecanoyl','C(=O)CCCCCCCCCCCCCCCCCC'],
			   '19:1(9Z)' => ['(9Z-nonadecenoyl)','C(=O)CCCCCCC\C=C/CCCCCCCCC'],
			   '19:1(12Z)' => ['(9Z-nonadecenoyl)','C(=O)CCCCCCCCCC\C=C/CCCCCC'],
			   '19:2(10Z,13Z)' => ['(10Z,13Z-nonadecadienoyl)','C(=O)CCCCCCCC\C=C/C\C=C/CCCCC'],
			   '20:0' => ['(eicosanoyl)','C(=O)CCCCCCCCCCCCCCCCCCC'],
				 #Original: '20:0e' => ['eicosyl','C(=O)CCCCCCCCCCCCCCCCCCCC'],
				 #Fixed
			   '20:0e' => ['eicosyl','C(=O)CCCCCCCCCCCCCCCCCCC'],
			   'O-20:0' => ['[eicosyl','CCCCCCCCCCCCCCCCCCCC'],
			   '20:0p' => ['(1Z-eicosenyl)','C=CCCCCCCCCCCCCCCCCCC'],
			   'P-20:0' => ['(1Z-eicosenyl)','C=CCCCCCCCCCCCCCCCCCC'],
			   'O-20:1(1Z)' => ['(1Z-eicosenyl)','C=CCCCCCCCCCCCCCCCCCC'],
			   '20:1n9' => ['(11Z-eicosenoyl)','C(=O)CCCCCCCCC\C=C/CCCCCCCC'],
			   '20:1(9Z)' => ['(9Z-eicosenoyl)','C(=O)CCCCCCC\C=C/CCCCCCCCCC'],
			   '20:1(11Z)' => ['(11Z-eicosenoyl)','C(=O)CCCCCCCCC\C=C/CCCCCCCC'],
			   'o-20:1n9' => ['(11Z-eicosenyl)','CCCCCCCCCC\C=C/CCCCCCCC'],
			   'o-20:1(11Z)' => ['(11Z-eicosenyl)','CCCCCCCCCC\C=C/CCCCCCCC'],
			   '20:1(11E)' => ['(11E-eicosenoyl)','C(=O)CCCCCCCCC\C=C\CCCCCCCC'],
			   '20:1(13Z)' => ['(13Z-eicosenoyl)','C(=O)CCCCCCCCCCC\C=C/CCCCCC'],
			   '20:1(13E)' => ['(13E-eicosenoyl)','C(=O)CCCCCCCCCCC/C=C/CCCCCC'],
			   '20:2n6' =>  ['(11Z,14Z-eicosadienoyl)','C(=O)CCCCCCCCC\C=C/C\C=C/CCCCC'],
			   '20:2(11Z,14Z)' => ['(11Z,14Z-eicosadienoyl)','C(=O)CCCCCCCCC\C=C/C\C=C/CCCCC'],
			   '20:2(5Z,8Z)' => ['(5Z,8Z-eicosadienoyl)','C(=O)CCC\C=C/C\C=C/CCCCCCCCCCC'],
			   '20:3n6' => ['(8Z,11Z,14Z-eicosatrienoyl)','C(=O)CCCCCC\C=C/C\C=C/C\C=C/CCCCC'],
			   '20:3(8Z,11Z,14Z)' => ['(8Z,11Z,14Z-eicosatrienoyl)','C(=O)CCCCCC\C=C/C\C=C/C\C=C/CCCCC'],
			   '20:3n9' => ['(5Z,8Z,11Z-eicosatrienoyl)','C(=O)CCC\C=C/C\C=C/C\C=C/CCCCCCCC'],
			   '20:3(11Z,14Z,17Z)' => ['(11Z,14Z,17Z-eicosatrienoyl)','C(=O)CCCCCCCCC\C=C/C\C=C/C\C=C/CC'],
			   '20:3(5Z,8Z,11Z)' => ['(5Z,8Z,11Z-eicosatrienoyl)','C(=O)CCC\C=C/C\C=C/C\C=C/CCCCCCCC'],
			   '20:4(5Z,8Z,11Z,13E)' => ['(5Z,8Z,11Z,13E-eicosatetraenoyl)','C(=O)CCC\C=C/C\C=C/C\C=C/C=C/CCCCCC'],

			   '20:4n6' => ['(5Z,8Z,11Z,14Z-eicosatetraenoyl)','C(=O)CCC\C=C/C\C=C/C\C=C/C\C=C/CCCCC'],
			   '20:4(5Z,8Z,11Z,14Z)' => ['(5Z,8Z,11Z,14Z-eicosatetraenoyl)','C(=O)CCC\C=C/C\C=C/C\C=C/C\C=C/CCCCC'],
			   '20:4(5Z,8Z,11Z,14Z)e' => ['(5Z,8Z,11Z,14Z-eicosatetraenoyl)','CCCC\C=C/C\C=C/C\C=C/C\C=C/CCCCC'],

			   '18:1(9Z)e' => ['(9Z-octadecenoyl)','CCCCCCCC\C=C/CCCCCCCC'],

			   '20:4(5Z,8Z,10E,14Z)' => ['(5Z,8Z,10E,14Z-eicosatetraenoyl)','C(=O)CCC\C=C/C\C=C/C=C/CC\C=C/CCCCC'],
			   '20:4(5E,8E,11E,14E)' => ['(5E,8E,11E,14E-eicosatetraenoyl)','C(=O)CCC/C=C/C/C=C/C/C=C/C/C=C/CCCCC'],
			   '20:4(6E,8Z,11Z,14Z)' => ['(6E,8Z,11Z,14Z-eicosatetraenoyl)','C(=O)CCCC/C=C/C=C\C\C=C/C\C=C/CCCCC'],
			   '20:4(7E,10E,13E,16E)' => ['(7E,10E,13E,16E-eicosatetraenoyl)','C(=O)CCCCC/C=C/C/C=C/C/C=C/C/C=C/CCC'],
			   '20:4(8E,11E,14E,17E)' => ['(8E,11E,14E,17E-eicosatetraenoyl)','C(=O)CCCCCC/C=C/C/C=C/C/C=C/C/C=C/CC'],
			   '20:4n3' =>['(8Z,11Z,14Z,17Z-eicosapentaenoyl)','C(=O)CCCCCC/C=C\C/C=C\C/C=C\C/C=C\CC'],
			   '20:4(8Z,11Z,14Z,17Z)'=>['(8Z,11Z,14Z,17Z-eicosapentaenoyl)','C(=O)CCCCCC/C=C\C/C=C\C/C=C\C/C=C\CC'],
			   '20:5n3' => ['(5Z,8Z,11Z,14Z,17Z-eicosapentaenoyl)','C(=O)CCC/C=C\C/C=C\C/C=C\C/C=C\C/C=C\CC'],
			   '20:5(5Z,8Z,11Z,14Z,17Z)' => ['(5Z,8Z,11Z,14Z,17Z-eicosapentaenoyl)','C(=O)CCC/C=C\C/C=C\C/C=C\C/C=C\C/C=C\CC'],
			   '21:0' => ['heneicosanoyl','C(=O)CCCCCCCCCCCCCCCCCCCC'],
			   'o-22:0' => ['docosanyl','CCCCCCCCCCCCCCCCCCCCCC'],
			   '22:0' => ['docosanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCC'],
			   '22:1n9'  => ['(13Z-docosenoyl)','C(=O)CCCCCCCCCCC/C=C\CCCCCCCC'],
			   '22:1(9Z)' => ['(9Z-docosenoyl)','C(=O)CCCCCCC/C=C\CCCCCCCCCCCC'],
			   '22:1(11Z)' => ['(11Z-docosenoyl)','C(=O)CCCCCCCCC/C=C\CCCCCCCCCC'],
			   '22:1(13Z)' => ['(13Z-docosenoyl)','C(=O)CCCCCCCCCCC/C=C\CCCCCCCC'],
			   'o-22:1n9' => ['(13Z-docosenyl)','C(=O)CCCCCCCCCCC/C=C\CCCCCCCC'],
			   'o-22:1(13Z)' => ['(13Z-docosenyl)','C(=O)CCCCCCCCCCC/C=C\CCCCCCCC'],
			   '22:2n6' => ['(13Z,16Z-docosadienoyl)','C(=O)CCCCCCCCCCC/C=C\C/C=C\CCCCC'],
			   '22:2(13Z,16Z)' => ['(13Z,16Z-docosadienoyl)','C(=O)CCCCCCCCCCC/C=C\C/C=C\CCCCC'],
			   '22:2(9Z,11Z)' => ['(9Z,11Z-docosadienoyl)','C(=O)CCCCCCC/C=C\C=C/CCCCCCCCCC'],
			   '22:2(6Z,13Z)' => ['(6Z,13Z-docosadienoyl)','C(=O)CCCC/C=C\CCCCC/C=C\CCCCCCCC'],
			   'o-22:2n6' => ['(13Z,16Z-docosadienyl)','CCCCCCCCCCCC/C=C\C/C=C\CCCCC'],
			   'o-22:2(13Z,16Z)' => ['(13Z,16Z-docosadienyl)','CCCCCCCCCCCC/C=C\C/C=C\CCCCC'],
			   '22:3(6Z,9Z,12Z)' => ['(6Z,9Z,12Z-docosenoyl)','C(=O)CCCC\C=C/C\C=C/C\C=C/CCCCCCCCC'],
			   '22:3(10Z,13Z,16Z)' => ['(10Z,13Z,16Z-docosenoyl)','C(=O)CCCCCCCC\C=C/C\C=C/C\C=C/CCCCC'],
         '22:4n6' => ['(7Z,10Z,13Z,16Z-docosatetraenoyl)','C(=O)CCCCC/C=C\C/C=C\C/C=C\C/C=C\CCCCC'],
			   '22:4(7Z,10Z,13Z,16Z)' => ['(7Z,10Z,13Z,16Z-docosatetraenoyl)','C(=O)CCCCC/C=C\C/C=C\C/C=C\C/C=C\CCCCC'],
			   '22:4(10Z,13Z,16Z,19Z)' => ['(10Z,13Z,16Z,19Z-docosatetraenoyl)','C(=O)CCCCCCCC/C=C\C/C=C\C/C=C\C/C=C\CC'],
         '22:5n6' => ['(4Z,7Z,10Z,13Z,16Z-docosapentaenoyl)','C(=O)CC/C=C\C/C=C\C/C=C\C/C=C\C/C=C\CCCCC'],
			   '22:5(4Z,7Z,10Z,13Z,16Z)' => ['(4Z,7Z,10Z,13Z,16Z-docosapentaenoyl)','C(=O)CC/C=C\C/C=C\C/C=C\C/C=C\C/C=C\CCCCC'],
			   '22:5n3' => ['(7Z,10Z,13Z,16Z,19Z-docosapentaenoyl)','C(=O)CCCCC/C=C\C/C=C\C/C=C\C/C=C\C/C=C\CC'],
			   '22:5(7Z,10Z,13Z,16Z,19Z)' => ['(7Z,10Z,13Z,16Z,19Z-docosapentaenoyl)','C(=O)CCCCC/C=C\C/C=C\C/C=C\C/C=C\C/C=C\CC'],
			   '22:6(4Z,7Z,10Z,12E,16Z,19Z)' => ['(4Z,7Z,10Z,12E,16Z,19Z-docosahexaenoyl)','C(=O)CC/C=C\C/C=C\C/C=C\C=C\C\C/C=C\C/C=C\CC'],
			   '22:6n3' => ['(4Z,7Z,10Z,13Z,16Z,19Z-docosahexaenoyl)','C(=O)CC/C=C\C/C=C\C/C=C\C/C=C\C/C=C\C/C=C\CC'],
			   '22:6(4Z,7Z,10Z,13Z,16Z,19Z)' => ['(4Z,7Z,10Z,13Z,16Z,19Z-docosahexaenoyl)','C(=O)CC/C=C\C/C=C\C/C=C\C/C=C\C/C=C\C/C=C\CC'],
			   '23:0' => ['tricosanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCC'],
			   '23:1(9Z)' => ['9Z-tricosanoyl','C(=O)CCCCCCC/C=C\CCCCCCCCCCCCC'],
			   '23:1(11Z)' => ['11Z-tricosanoyl','C(=O)CCCCCCCCC/C=C\CCCCCCCCCCC'],
			   'o-22:3n6' => ['(10Z,13Z,16Z-docosatrienyl)','CCCCCCCCC\C=C/C\C=C/C\C=C/CCCCC'],
			   'o-22:3(10Z,13Z,16Z)' => ['(10Z,13Z,16Z-docosatrienyl)','CCCCCCCCC\C=C/C\C=C/C\C=C/CCCCC'],
			   'o-24:0' => ['tetracosanyl','CCCCCCCCCCCCCCCCCCCCCCCC'],
			   '24:0' => ['tetracosanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCC'],
			   '24:1n9' => ['(15Z-tetracosenoyl)','C(=O)CCCCCCCCCCCCC/C=C\CCCCCCCC'],
			   '24:1(9Z)' => ['(9Z-tetracosenoyl)','C(=O)CCCCCCC/C=C\CCCCCCCCCCCCCC'],
			   '24:1(11Z)' => ['(11Z-tetracosenoyl)','C(=O)CCCCCCCCC/C=C\CCCCCCCCCCCC'],
			   '24:1(15Z)' => ['(15Z-tetracosenoyl)','C(=O)CCCCCCCCCCCCC/C=C\CCCCCCCC'],
			   '24:4(5Z,8Z,11Z,14Z)' => ['(5Z,8Z,11Z,14Z-tetracosatetraenoyl)','C(=O)CCC/C=C\C/C=C\C/C=C\C/C=C\CCCCCCCCC'],
			   '24:6(6Z,9Z,12Z,15Z,18Z,21Z)' => ['(6Z,9Z,12Z,15Z,18Z,21Z-tetracosahexaenoyl)','C(=O)CCCC/C=C\C/C=C\C/C=C\C/C=C\C/C=C\C/C=C\CC'],  #smiles corrected
			   '25:0' => ['pentacosanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCC'],
			   '25:1(9Z)' => ['(9Z-pentacosenoyl)','C(=O)CCCCCCC/C=C\CCCCCCCCCCCCCCC'],
			   '25:1(11Z)' => ['11Z-pentacosanoyl','C(=O)CCCCCCCCC/C=C\CCCCCCCCCCCCC'],
			   '25:1(15Z)' => ['15Z-pentacosanoyl','C(=O)CCCCCCCCCCCCC/C=C\CCCCCCCCC'],
			   '26:0' => ['hexacosanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '26:1(5Z)' => ['(5Z-hexacosenoyl)','C(=O)CCC/C=C\CCCCCCCCCCCCCCCCCCCC'],
			   '26:1(9Z)' => ['(9Z-hexacosenoyl)','C(=O)CCCCCCC/C=C\CCCCCCCCCCCCCCCC'],   #smiles corrected
			   '26:1(11Z)' => ['(11Z-hexacosenoyl)','C(=O)CCCCCCCCC/C=C\CCCCCCCCCCCCCC'],
			   '26:1(17Z)' => ['(17Z-hexacosenoyl)','C(=O)CCCCCCCCCCCCCCC/C=C\CCCCCCCC'],
			   '26:2(5Z,9Z)' => ['(5Z,9Z-hexacosadienoyl)','C(=O)CCC/C=C\CC/C=C\CCCCCCCCCCCCCCCC'],
			   '26:2(5Z,9E)' => ['(5Z,9E-hexacosadienoyl)','C(=O)CCC/C=C\CC/C=C/CCCCCCCCCCCCCCCC'],
			   '26:2(5E,9Z)' => ['(5Z,9E-hexacosadienoyl)','C(=O)CCC/C=C/CC/C=C\CCCCCCCCCCCCCCCC'],
			   '27:0' => ['heptacosanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '27:1(5Z)' => ['(5Z-heptacosanoyl)','C(=O)CCC/C=C\CCCCCCCCCCCCCCCCCCCCC'],
			   '27:1(9Z)' => ['(9Z-heptacosanoyl)','C(=O)CCCCCCC/C=C\CCCCCCCCCCCCCCCCC'],
			   '27:1(11Z)' => ['(11Z-heptacosanoyl)','C(=O)CCCCCCCCC/C=C\CCCCCCCCCCCCCCC'],
			   '28:0' => ['octacosanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '28:1(5Z)' => ['(5Z-octocosanoyl)','C(=O)CCC/C=C\CCCCCCCCCCCCCCCCCCCCCC'],
			   # Original '28:1(9Z)' => ['(9Z-octocosanoyl)','C(=O)CCCCCCCC/C=C\CCCCCCCCCCCCCCCCC'],
			   '28:1(9Z)' => ['(9Z-octocosanoyl)','C(=O)CCCCCCC/C=C\CCCCCCCCCCCCCCCCCC'],

			   #Original '28:1(11Z)' => ['(11Z-octocosanoyl)','C(=O)CCCCCCCCCC/C=C\CCCCCCCCCCCCCCC'],
			   #Fixed
			   '28:1(11Z)' => ['(11Z-octocosanoyl)','C(=O)CCCCCCCCC/C=C\CCCCCCCCCCCCCCCC'],
			   '29:0' => ['nonacosanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '30:0' => ['tricontanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '31:0' => ['hentricontanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '32:0' => ['dotricontanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '33:0' => ['tritricontanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '34:0' => ['tetratricontanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '35:0' => ['pentatricontanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '36:0' => ['hexatricontanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '37:0' => ['heptatricontanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '38:0' => ['octatricontanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'],
			   '39:0' => ['nonatricontanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'],

				#added structures
			   '14:1(7Z)' => ['(7Z,tetradecenoyl)','C(=O)CCCCC\C=C/CCCCCC'],
			   '17:0 CYCLO 9-10'=>['(heptadec-9-10-cyclo-anoyl)','C(=O)CCCCCCCC1CC1CCCCCC'], # 9,10-methylenehexacecanoic acid
			   '17:0cycw7c'=>['(heptadec-9-10-cyclo-anoyl)','C(=O)CCCCCCCC1CC1CCCCCC'],# 9,10-methylenehexacecanoic acid
			   '19:1(9Z) CYCLO w10c'=>['9,10-methylene-octadec-9-enoyl','C(=O)CCCCCCCCCC1=C(CCCCCC)C1'], #sterculic acid, 9,10-methylene-9-octadecenoic acid
			   '19:0cycv8c'=>['(heptadec-11-12-cyclo-anoyl)','C(=O)CCCCCCCCCC1CC1CCCCCC'], #phytomonic acid, cis-11,12-Methyleneoctadecanoic acid, lactobacillic acid
			   '19:0cycw7c'=>['(heptadec-11-12-cyclo-anoyl)','C(=O)CCCCCCCCCC1CC1CCCCCC'], #phytomonic acid, cis-11,12-Methyleneoctadecanoic acid, lactobacillic acid
			   '19:0cycw9c'=>['(heptadec-8-9-cyclo-anoyl)','C(=O)CCCCCCCC1CC1CCCCCCCC'], # cis-9,10-Methyleneoctadecanoic acid, dihydrosterculic acid
			   '15:0cyclo'=>['cis-9,10-Methylenetetradecanoic acid','C(=O)CCCCCCCC1CC1CCCC'],
			   '10:0(3-OH)'=>['3-hydroxydecanoyl','C(=O)CC(O)CCCCCCC'], #PMID 22753057
			   '12:0(3-OH)'=>['3-hydroxydodecanoyl','C(=O)CC(O)CCCCCCCCC'], #PMID: 4902888
			   '14:0(3-OH)'=>['3-hydroxytetradecanoyl','C(=O)CC(O)CCCCCCCCCCC'], #PMID 22753057
			   '19:iso'=>['17-methylocatdecanoyl','C(=O)CCCCCCCCCCCCCCCC(C)C'],#PMID: 12450817
			   '17:1(5Z) cycw7c'=>['9,10-methylene-hexadec-5-enoyl','CCCCCCC1CC1CCC=CCCCC=O'], #PMID: 9560808, lipidlibrary.aocs.org/lipids/fa_cycl/file.pdf, PMID: 14453599 (E. coli)
			   '18:1(8Z) cycw9c'=>['8,9-methylene-heptadec-8-enoyl','C(=O)CCCCCCC1=C(CCCCCCCC)C1'], #malvalic acid, 2-octyl-1-cyclopropene-1-heptanoic acid
			   '19:0cycw8c'=>['9-(2-heptylcyclopropyl)nonanoyl','C(=O)CCCCCCCCC1CC1CCCCCCC'],# 10,11-methylene-octadecanoyl, E.coli (Yurtsever D. (2007). Fatty acid methyl ester profiling of Enterococcus and Esherichia coli for microbial source tracking. M.sc. Thesis. Villanova University: U.S.A)
			   '21:0cycw9c'=>['10-(2-octylcyclopropyl)decanoyl','C(=O)CCCCCCCCCC1CC1CCCCCCCC'], #cis-11,12-methylene-5-eicosenoic acid, lipidlibrary.aocs.org/lipids/fa_cycl/file.pdf
			   '0:0'=>['',''],

			   #''=>[]'','CCCC(=CC=CCCC1CC1CCC(=O)O)Br'] #majusculoic acid
			   '10:0(6-OH)' => ['6-hydroxydecanoyl','C(=O)CCCCC(O)CCCC'],
			   '14:0(2-OH)' => ['2-hydroxytetradecanoyl','C(=O)C(O)CCCCCCCCCCCC'],
			   '10:2(2E,4Z)' => ['(2E,4Z-decenoyl)','CCCCC\C=C/C=C/C=O'],
			   '10:1(9E)' => ['(9E-decenoyl)','C=CCCCCCCCC=O'],
			   '14:2(3E,5E)' => ['(3E,5E-tetradecenoyl)','CCCCCCCC\C=C\C=C\CC=O'],
			   '12:1(2E)' => ['(2E-dodecenoyl)','CCCCCCCCC\C=C\C=O'],
			   '14:1(2E)' => ['(2E-tetradecenoyl)','CCCCCCCCCCC\C=C\C=O'],
			   '14:1(3-OH,9Z)' => ['(3-hydroxy-9Z-tetradecenoyl)','CCCC\C=C/CCCCCC(O)CC=O'],
			   '14:1(9Z)(OH)' => ['(3-hydroxy-9Z-tetradecenoyl)','CCCC\C=C/CCCCCC(O)CC=O'],
			   '16:1(3-OH,9Z)' =>	['(3-hydroxy-9Z-hexadecenoyl)','CCCCCC\C=C/CCCCCC(O)CC=O'],
			   '16:1(9Z)(OH)' =>	['(3-hydroxy-9Z-hexadecenoyl)','CCCCCC\C=C/CCCCCC(O)CC=O'],
			   '16:2(3-OH,9Z,12Z)' =>	['(3-hydroxy-9Z,12Z-hexadecenoyl)','CCC\C=C/C\C=C/CCCCCC(O)CC=O'],
			   '16:1(3-OH,9E)' => ['(3-hydroxy-9E-hexadecenoyl)','CCCCCC\C=C\CCCCCC(O)CC=O'],
			   '16:0(2-OH)' => ['2-hydroxyhexadecanoyl','CCCCCCCCCCCCCCC(O)C=O'],
			   '18:1(3-OH,11Z)' => ['(3-hydroxy-11Z-octadecenoyl)','CCCCCC\C=C/CCCCCCCC(O)CC=O'],
			   '18:1(3-OH,9Z)' => ['(3-hydroxy-9Z-octadecenoyl)','CCCCCCCC\C=C/CCCCCC(O)CC=O'],
			   '4:1(2E)' => [('2E-butyrl'),'C\C=C\C=O'],
			   '4:0(3-OH)'=>['3-hydroxybutryl','CC(O)CC=O'],
			   '6:1(2E)' => ['(2E-hexenoyl)','CCC\C=C\C=O'],
			   '12:0(2-OH)' => ['2-hydroxydodecanoyl','CCCCCCCCCCC(O)C=O'],

			   '22:1(13Z)(OH)' =>	['(3-hydroxy-13Z-docosenoyl)','CCCCCCCC\C=C/CCCCCCCCCC(O)CC=O'],
			   '22:2(13Z,16Z)(OH)' =>	['(3-hydroxy-13Z,16Z-docosenoyl)','CCCCC\C=C/C\C=C/CCCCCCCCCC(O)CC=O'],
			   '24:1(15Z)(OH)' =>	['(3-hydroxy-15Z-tetracosenoyl)','CCCCCCCC\C=C/CCCCCCCCCCCC(O)CC=O'],
		

		# Hydroxy fatty acids in humans (March 5, 2014)
         '20:0(2R-OH)' => ['2(R)-hydroxyicosanoyl','C(=O)[C@@H](O)CCCCCCCCCCCCCCCCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         '22:0(2R-OH)' => ['2(R)-hydroxydocosanoyl','C(=O)[C@@H](O)CCCCCCCCCCCCCCCCCCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm  CCCCCCCCCCCCCCCCCC[C@@H](O)C=O,
         '18:0(9-OH)' => ['9-hydroxyoctadecanoyl','C(=O)CCCCCCCC(O)CCCCCCCCC'],  # PMID: 2505334
         '18:0(13-OH)' => ['13-hydroxyoctadecanoyl','C(=O)CCCCCCCCCCCC(O)CCCCC'], # PMID: 2505334, 13-HODE
         '17:0(12-OH)' => ['12-hydroxyheptadecanoyl','C(=O)CCCCCCCCCCC(O)CCCCC'], # PMID: 9439461
         '20:0(12-OH)' => ['12-hydroxyicosanoyl','C(=O)CCCCCCCCCCC(O)CCCCCCCC'], # PMID: 9439461
         '20:0(15-OH)' => ['15-hydroxyicosanoyl','C(=O)CCCCCCCCCCCCCC(O)CCCCC'], #
         '16:0(2-OH,3R-Me,7-Me,11R-Me,15-Me)'=>['2-hydroxyphytanoyl','O=CC(O)C(C)CCCC(C)CCCC(C)CCCC(C)C'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         '18:0(12-OH)' => ['13-hydroxyoctadecanoyl','C(=O)CCCCCCCCCCC(O)CCCCCC'],
         #3-OH hydoxy acids. #Occur also at free fatty acids or as acyl carnitines. Also occur in sphingolipids
         '15:0(3-OH,2-Me,6-Me,10-Me,14-Me)'=>['3-hydroxypristanoyl','CC(C)CCCC(C)CCCC(C)CCC(O)C(C)C=O'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm, PMID: 9266376
         '6:0(3-OH)'=>['3-hydroxyhexanoyl','C(=O)CC(O)CCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         '7:0(3-OH)'=>['3-hydroxyheptanoyl','C(=O)CC(O)CCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         '8:0(3-OH)'=>['3-hydroxyoctanoyl','C(=O)CC(O)CCCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         '9:0(3-OH)'=>['3-hydroxyononanoyl','C(=O)CC(O)CCCCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         #'10:0(3-OH)'=>['3-hydroxydecanoyl','C(=O)CC(O)CCCCCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         '11:0(3-OH)'=>['3-hydroxyundecanoyl','C(=O)CC(O)CCCCCCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         #'12:0(3-OH)'=>['3-hydroxydodecanoyl','C(=O)CC(O)CCCCCCCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         '13:0(3-OH)'=>['3-hydroxytridecanoyl','C(=O)CC(O)CCCCCCCCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         #'14:0(3-OH)'=>['3-hydroxytetradecanoyl','C(=O)CC(O)CCCCCCCCCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         '15:0(3-OH)'=>['3-hydroxypentadecanoyl','C(=O)CC(O)CCCCCCCCCCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm
         '16:0(3-OH)'=>['3-hydroxyhexadecanoyl','C(=O)CC(O)CCCCCCCCCCCCC'], # http://lipidlibrary.aocs.org/Lipids/fa_oxy/index.htm

         #O-acyl long-chain fatty acids for ceramides in humans (they are hydroxylatd at the terminal carbon)


         # Epoxy fatty acids
         '18:0(9Ep)' => ['9,10-epoxyoctadecanoyl','C(=O)CCCCCCCC(O1)C1CCCCCCCC'], #http://monographs.iarc.fr/ENG/Monographs/vol71/mono71-98.pdf, PMID: 20629947


         #Other w-1 hydroxylated long-chain fatty acids
         #'16:0(15-OH)' => ['15hydroxyhexadecanoyl','C(=O)CCCCCCCCCCCCCC(O)C'],
         #'18:0(17-OH)' => ['15hydroxyhexadecanoyl','C(=O)CCCCCCCCCCCCCCCC(O)C'],

         #Furanoid fatty acids. in humans ,they occur mainly in phospholipids //PMID:16296395
         'DiMe(9,3)' => ['10,13-epoxy-11-methylhexadeca-10,12-dienoyl','C(=O)CCCCCCCC(C1=C(C)C(C)=C(O1)CCC)'], #F1
         'MonoMe(9,5)' => ['10,13-epoxy-11-methyloctadeca-10,12-dienoyl','C(=O)CCCCCCCC(C1=C(C)C(H)=C(O1)CCCCC)'], #F2
         'DiMe(9,5)' => ['10,13-epoxy-11,12-dimethyloctadeca-10,12-dienoyl','C(=O)CCCCCCCC(C1=C(C)C(C)=C(O1)CCCCC)'], #F3 // F20 (Helmut Guth and Werner Grosch (1997). Stability of furanoid fatty acids in soybean oil. Journal of the American Oil Chemists' Society 1997, Volume 74, Issue 3, pp 323-326)
         'MonoMe(11,3)' => ['12,15-epoxy-13-methyleicosa-12,14-dienoyl','C(=O)CCCCCCCCCC(C1=C(C)C(H)=C(O1)CCC)'],
         'DiMe(11,3)' => ['12,15-epoxy-13,14-dimethyleicosa-12,14-dienoyl','C(=O)CCCCCCCCCC(C1=C(C)C(C)=C(O1)CCC)'], #F4 // F22
         'MonoMe(11,5)' => ['12,15-epoxy-13-methyleicosa-12,14-dienoyl','C(=O)CCCCCCCCCC(C1=C(C)C(H)=C(O1)CCCCC)'], #F5
         'DiMe(11,5)' => ['12,15-epoxy-13,14-dimethyleicosa-12,14-dienoyl','C(=O)CCCCCCCCCC(C1=C(C)C(C)=C(O1)CCCCC)'], #F6
         'MonoMe(13,5)' => ['14,17-epoxy-15,16-dimethyldocosa-14,16-dienoyl','C(=O)CCCCCCCCCCCC(C1=C(C)C(H)=C(O1)CCCCC)'], #F7
         'DiMe(13,5)' => ['14,17-epoxy-15-methyldocosa-14,16-dienoyl','C(=O)CCCCCCCCCCCC(C1=C(C)C(C)=C(O1)CCCCC)'], #F8
				 #Added iso on April 13th
						 #Nomencalture is i-15:0 = 13-methyl-tetradecanoyl
						 #http://www.midi-inc.com/pdf/MIS_Fatty_Acid_Naming.pdf
					 'i-12:0' => ['10-methylundecanoyl','C(=O)CCCCCCCCC(C)C'],
					 'i-13:0' => ['11-methyldodecanoyl','C(=O)CCCCCCCCCC(C)C'],
					 'i-14:0' => ['12-methyltridecanoyl','C(=O)CCCCCCCCCCC(C)C'],
					 'i-15:0' => ['13-methyltetradecanoyl','C(=O)CCCCCCCCCCCC(C)C'],
					 'i-16:0' => ['14-methylpentadecanoyl','C(=O)CCCCCCCCCCCCC(C)C'],
					 'i-17:0' => ['15-methylhexadecanoyl','C(=O)CCCCCCCCCCCCCC(C)C'],
					 'i-18:0' => ['16-methylheptadecanoyl','C(=O)CCCCCCCCCCCCCCC(C)C'],
					 'i-19:0' => ['17-methyloctadecanoyl','C(=O)CCCCCCCCCCCCCCCC(C)C'],
					 'i-20:0' => ['18-methylnonadecanoyl','C(=O)CCCCCCCCCCCCCCCCC(C)C'],
					 'i-21:0' => ['19-methyleicosanoyl','C(=O)CCCCCCCCCCCCCCCCCC(C)C'],
					 'i-22:0' => ['20-methylheneicosanoyl','C(=O)CCCCCCCCCCCCCCCCCCC(C)C'],
					 'i-24:0' => ['22-methyltricosanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCC(C)C'],
				 # Added AnteIso on April 13th
					 #Nomencalture: http://www.midi-inc.com/pdf/MIS_Fatty_Acid_Naming.pdf
					 # a-15:0 = 12-methyltetradecanoyl
					'a-13:0' => ['10-methyldodecanoyl','C(=O)CCCCCCCCC(C)CC'],
					'a-15:0' => ['12-methyltetradecanoyl','C(=O)CCCCCCCCCCC(C)CC'],
					'a-17:0' => ['14-methylhexadecanoyl','C(=O)CCCCCCCCCCCCC(C)CC'],
					'a-21:0' => ['18-methyleicosanoyl','C(=O)CCCCCCCCCCCCCCCCC(C)CC'],
					'a-25:0' => ['22-methyltetracosanoyl','C(=O)CCCCCCCCCCCCCCCCCCCCC(C)CC'],

		# Adding furan fatty acids according to abbreviations of Determination of Furan Fatty Acids in Food Samples 
		# (Vetter et al 2012)
					
          '3D5' => ['3-(3,4-dimethyl-5-pentylfuran-2-yl)propanoyl','CCCCCC1=C(C)C(C)=C(CCC(O)=O)O1'],
          '3M5' => ['3-(3-methyl-5-pentylfuran-2-yl)propanoyl','CCCCCC1=CC(C)=C(CCC(O)=O)O1'],
          '5D5' => ['5-(3,4-dimethyl-5-pentylfuran-2-yl)pentanoyl','CCCCCC1=C(C)C(C)=C(CCCCC(O)=O)O1'],
          '5M5' => ['5-(3-methyl-5-pentylfuran-2-yl)pentanoyl','CCCCCC1=CC(C)=C(CCCCC(O)=O)O1'],
          '5M7' => ['5-(5-heptyl-3-methylfuran-2-yl)pentanoyl','CCCCCCCC1=CC(C)=C(CCCCC(O)=O)O1'],
          '6F6' => ['6-(5-hexylfuran-2-yl)hexanoyl','CCCCCCC1=CC=C(CCCCCC(O)=O)O1'],
          '7D3' => ['7-(3,4-dimethyl-5-propylfuran-2-yl)heptanoyl','CCCC1=C(C)C(C)=C(CCCCCCC(O)=O)O1'],
          '7D5' => ['7-(3,4-dimethyl-5-pentylfuran-2-yl)heptanoyl','CCCCCC1=C(C)C(C)=C(CCCCCCC(O)=O)O1'],
          '7D6' => ['7-(5-hexyl-3,4-dimethylfuran-2-yl)heptanoyl','CCCCCCC1=C(C)C(C)=C(CCCCCCC(O)=O)O1'],
          '7D7' => ['7-(5-heptyl-3,4-dimethylfuran-2-yl)heptanoyl','CCCCCCCC1=C(C)C(C)=C(CCCCCCC(O)=O)O1'],
          '7F5' => ['7-(5-pentylfuran-2-yl)heptanoyl','CCCCCC1=CC=C(CCCCCCC(O)=O)O1'],
          '7F7' => ['7-(5-heptylfuran-2-yl)heptanoyl','CCCCCCCC1=CC=C(CCCCCCC(O)=O)O1'],
          '7M3' => ['7-(3-methyl-5-propylfuran-2-yl)heptanoyl','CCCC1=CC(C)=C(CCCCCCC(O)=O)O1'],
          '7M5' => ['7-(3-methyl-5-pentylfuran-2-yl)heptanoyl','CCCCCC1=CC(C)=C(CCCCCCC(O)=O)O1'],
          '8D5' => ['8-(3,4-dimethyl-5-pentylfuran-2-yl)octanoyl','CCCCCC1=C(C)C(C)=C(CCCCCCCC(O)=O)O1'],
          '8F4' => ['8-(5-butylfuran-2-yl)octanoyl','CCCCC1=CC=C(CCCCCCCC(O)=O)O1'],
          '8F5' => ['8-(5-pentylfuran-2-yl)octanoyl','CCCCCC1=CC=C(CCCCCCCC(O)=O)O1'],
          '8F6' => ['8-(5-hexylfuran-2-yl)octanoyl','CCCCCCC1=CC=C(CCCCCCCC(O)=O)O1'],
          '9D3' => ['9-(3,4-dimethyl-5-propylfuran-2-yl)nonanoyl','CCCC1=C(C)C(C)=C(CCCCCCCCC(O)=O)O1'],
          '9D4' => ['9-(5-butyl-3,4-dimethylfuran-2-yl)nonanoyl','CCCCC1=C(C)C(C)=C(CCCCCCCCC(O)=O)O1'],

          # this version of side chain is the proper format
          '9D5' => ['9-(3,4-dimethyl-5-pentylfuran-2-yl)nonanoyl','C(=O)CCCCCCCCC(O1)=C(C)C(C)=C1CCCCC'],
          										# side chain was: 'CCCCCC1=C(C)C(C)=C(CCCCCCCCC(O)=O)O1'

          '9D6' => ['9-(5-hexyl-3,4-dimethylfuran-2-yl)nonanoyl','CCCCCCC1=C(C)C(C)=C(CCCCCCCCC(O)=O)O1'],
          '9F5' => ['9-(5-pentylfuran-2-yl)nonanoyl','CCCCCC1=CC=C(CCCCCCCCC(O)=O)O1'],
          '9M3' => ['9-(3-methyl-5-propylfuran-2-yl)nonanoyl','CCCCCC1=C(C)C(C)=C(CCCCCCCCC(O)=O)O1'],
          '9M4' => ['9-(5-butyl-3-methylfuran-2-yl)nonanoyl','CCCCC1=CC(C)=C(CCCCCCCCC(O)=O)O1'],
          '9M5' => ['9-(3-methyl-5-pentylfuran-2-yl)nonanoyl','CCCC1=CC(C)=C(CCCCCCCCC(O)=O)O1'],
          '9M6' => ['9-(5-hexyl-3-methylfuran-2-yl)nonanoyl','CCCCCCC1=CC(C)=C(CCCCCCCCC(O)=O)O1'],
          '10D3' => ['10-(3,4-dimethyl-5-propylfuran-2-yl)decanoyl','CCCC1=C(C)C(C)=C(CCCCCCCCCC(O)=O)O1'],
          '10D5' => ['10-(3,4-dimethyl-5-pentylfuran-2-yl)decanoyl','CCCCCC1=C(C)C(C)=C(CCCCCCCCCC(O)=O)O1'],
          '11D2' => ['11-(5-ethyl-3,4-dimethylfuran-2-yl)undecanoyl','CCC1=C(C)C(C)=C(CCCCCCCCCCC(O)=O)O1'],
          '11D3' => ['11-(3,4-dimethyl-5-propylfuran-2-yl)undecanoyl','CCCC1=C(C)C(C)=C(CCCCCCCCCCC(O)=O)O1'],
          '11:1D3' => ['12,15-epoxy-13,14-dimethyloctadeca-10,12,14-trienoyl','CCCC1=C(C)C(C)=C(O1)\C=C\CCCCCCCCC(O)=O'],
          '11:1D5' => ['12,15-epoxy-13,14-dimethyleicosa-10,12,14-trienoyl','CCCCCC1=C(C)C(C)=C(O1)\C=C\CCCCCCCCC(O)=O'],
          '11D3:1' => ['12,15-epoxy-13,14-dimethyloctadeca-12,14,16-trienoyl','C\C=C\C1=C(C)C(C)=C(CCCCCCCCCCC(O)=O)O1'],
          '11D5:1' => ['12,15-epoxy-13,14-dimethyleicosa-12,14,16-trienoyl','CCC\C=C\C1=C(C)C(C)=C(CCCCCCCCCCC(O)=O)O1'],
          '11D4' => ['11-(5-butyl-3,4-dimethylfuran-2-yl)undecanoyl','CCCCC1=C(C)C(C)=C(CCCCCCCCCCC(O)=O)O1'],
          '11D5' => ['11-(3,4-dimethyl-5-pentylfuran-2-yl)undecanoyl','CCCCCC1=C(C)C(C)=C(CCCCCCCCCCC(O)=O)O1'],
          '11D6' => ['11-(5-hexyl-3,4-dimethylfuran-2-yl)undecanoyl','CCCCCCC1=C(C)C(C)=C(CCCCCCCCCCC(O)=O)O1'],
          '11M3' => ['11-(3-methyl-5-propylfuran-2-yl)undecanoyl','CCCC1=CC(C)=C(CCCCCCCCCCC(O)=O)O1'],
          '11M5' => ['11-(3-methyl-5-pentylfuran-2-yl)undecanoyl','CCCCCC1=CC(C)=C(CCCCCCCCCCC(O)=O)O1'],
          '11M7' => ['11-(5-heptyl-3-methylfuran-2-yl)undecanoyl','CCCCCCCC1=CC(C)=C(CCCCCCCCCCC(O)=O)O1'],
          '12D3' => ['12-(3,4-dimethyl-5-propylfuran-2-yl)dodecanoyl','CCCC1=C(C)C(C)=C(CCCCCCCCCCCC(O)=O)O1'],
          '12D5' => ['12-(3,4-dimethyl-5-pentylfuran-2-yl)dodecanoyl','CCCCCC1=C(C)C(C)=C(CCCCCCCCCCCC(O)=O)O1'],
          '13D3' => ['13-(3,4-dimethyl-5-propylfuran-2-yl)tridecanoyl','CCCC1=C(C)C(C)=C(CCCCCCCCCCCCC(O)=O)O1'],
          '13D5' => ['13-(3,4-dimethyl-5-pentylfuran-2-yl)tridecanoyl','CCCCCC1=C(C)C(C)=C(CCCCCCCCCCCCC(O)=O)O1'],
          '13M3' => ['13-(3-methyl-5-propylfuran-2-yl)tridecanoyl','CCCC1=CC(C)=C(CCCCCCCCCCCCC(O)=O)O1'],
          '13M5' => ['13-(3-methyl-5-pentylfuran-2-yl)tridecanoyl','CCCCCC1=CC(C)=C(CCCCCCCCCCCCC(O)=O)O1'],
          '15D3' => ['15-(3,4-dimethyl-5-propylfuran-2-yl)pentadecanoyl','CCCC1=C(C)C(C)=C(CCCCCCCCCCCCCCC(O)=O)O1'],
          '15D5' => ['15-(3,4-dimethyl-5-pentylfuran-2-yl)pentadecanoyl','CCCCCC1=C(C)C(C)=C(CCCCCCCCCCCCCCC(O)=O)O1'],
          '15M5' => ['15-(3-methyl-5-pentylfuran-2-yl)pentadecanoyl','CCCCCC1=CC(C)=C(CCCCCCCCCCCCCCC(O)=O)O1'],


         # Urofuranic acids in humans
         'U(3,3)' => ['3-carboxy-4-methyl-5-propyl-2-furanpropanoyl','C(=O)CC(C1=C(C(=O)O)C(C)=C(O1)CCC)'],
         'U(5,3)' => ['3-carboxy-4-methyl-5-pentyl-2-furanpropanoyl','C(=O)CC(C1=C(C(=O)O)C(C)=C(O1)CCCCC'],
         #'' => ['3-carboxy-4-methyl-5-??-2-??',''],
         #'' => ['3-carboxy-4-methyl-5-???-2-???','']


         # Addition of chains (base chains) for the new sphingolipids, since they have two chains
         # one is long base chain, and the other one is a side chain (NAcyl chain)!
         # Most are based on lipid maps structure drawing:
         #(http://www.lipidmaps.org/tools/structuredrawing/StrDraw.pl?Mode=SetupSPStrDraw)
         # **Note that all double bonds are in trans configuration and not cis
         # This is an example of the right stereochemsitry for the base chain:'C[C@@H](O)[C@@H](N)CCCCCCCCCCCCC'
	         'd16:0' => ["hexadecasphinganine", "C(O)CCCCCCCCCCCCC"],
	         'd16:1' => ["hexadecasphing-4-enine", 'C(O)/C=C/CCCCCCCCCCC'],
	         'd16:1(11E)' => ["11E-hexadecasphingenine", 'C(O)CCCCCCC/C=C/CCCC'],
	         'd16:2' => ["4E,8E-hexadecasphingdienine", 'C(O)\C=C\CC/C=C/CCCCCCC'],
	         'd17:0' => ["heptadecasphinganine", "C(O)CCCCCCCCCCCCCC"],
	         'd17:1' => ["heptadecasphing-4-enine", "C(O)/C=C/CCCCCCCCCCCC"],
	         'd17:1(10E)' => ["10E-heptadecasphingenine", "C(O)CCCCCC/C=C/CCCCCC"],
	         'd17:2' => ["4E,8E-heptadecasphingdienine", "C(O)/C=C/CC/C=C/CCCCCCCC"],
	         'd18:0' => ["sphinganine", "C(O)CCCCCCCCCCCCCCC"],
	         'd18:1' => ["sphing-4-enine", "C(O)/C=C/CCCCCCCCCCCCC"],
	         'd18:1(11E)' => ["11E-sphingenine", "C(O)CCCCCCC/C=C/CCCCCC"],
	         'd18:2' => ["4E,8E-sphingdienine", "C(O)/C=C/CC/C=C/CCCCCCCCC"],
	         'd18:2(9E,12E)' => ['9E,12E-sphingdienine','C(O)CCCCC/C=C/C/C=C/CCCCC'],
	         'd19:0' => ["nonadecasphinganine", "C(O)CCCCCCCCCCCCCCCC"],
	         'd19:1' => ["nonadecasphing-4-enine", "C(O)/C=C/CCCCCCCCCCCCCC"],
	         'd19:2' => ["4E,8E-nonadecasphingadienine", "C(O)/C=C/CC/C=C/CCCCCCCCCC"],
	         'd20:0' => ["eicosasphinganine", "C(O)CCCCCCCCCCCCCCCCC"],
	         'd20:1' => ["eicosasphing-4-enine", "C(O)/C=C/CCCCCCCCCCCCCCC"],
	         'd20:2' => ["4E,8E-eicosasphingdienine", "C(O)/C=C/CC/C=C/CCCCCCCCCCC"],
	         'd21:0' => ["heneicosasphinganine", "C(O)CCCCCCCCCCCCCCCCCC"],
	         'd22:0' => ["docosasphinganine", "C(O)CCCCCCCCCCCCCCCCCCC"],


	         'm16:0' => ["3-keto-hexadecasphinganine", "C(=O)CCCCCCCCCCCCC"],
	         #'m16:1' => ["C(=O)/C=C/CCCCCCCCCCC"],
	         #'m16:2' => ["C(=O)/C=C/CCCCCC/C=C/CCC"],
	         'm17:0' => ["3-keto-heptadecasphinganine", "C(=O)CCCCCCCCCCCCCC"],
	         #'m17:1' => ["C(=O)/C=C/CCCCCCCCCCCC"],
	         #'m17:2' => ["C(=O)/C=C/CCCCCCC/C=C/CCC"],
	         'm18:0' => ["3-keto-sphinganine", "C(=O)CCCCCCCCCCCCCCC"],
	         #'m18:1' => ["C(=O)/C=C/CCCCCCCCCCCCC"],
	         #'m18:2' => ["C(=O)/C=C/CCCCCCCC/C=C/CCC"],
	         'm19:0' => ["3-keto-nonadecasphinganine", "C(=O)CCCCCCCCCCCCCCCC"],
	         #'m19:1' => ["C(=O)/C=C/CCCCCCCCCCCCCC"],
	         #'m19:2' => ["C(=O)/C=C/CCCCCCCCC/C=C/CCC"],
	         'm20:0' => ["3-keto-eicosasphinganine", "C(=O)CCCCCCCCCCCCCCCCC"],
	         #'m20:1' => ["C(=O)/C=C/CCCCCCCCCCCCCCC"],
	         #'m20:2' => ["C(=O)/C=C/CCCCCCCCCC/C=C/CCC"],

	         't16:0' => ["4R-hydroxy-hexadecasphinganine", "C(O)C(O)CCCCCCCCCCCC"],
	         #'t16:1' => ["C(O)/C(O)=C/CCCCCCCCCCC"],
	         #'t16:2' => ["C(O)/C(O)=C/CCCCCC/C=C/CCC"],
	         't17:0' => ["4R-hydroxy-heptadecasphinganine", "C(O)C(O)CCCCCCCCCCCCC"],
	         #'t17:0' => ["CCCCCCCCCCCCC(O)C(O)"],
	         #'t17:1' => ["C(O)/C(O)=C/CCCCCCCCCCCC"],
	         #'t17:2' => ["C(O)/C(O)=C/CCCCCCC/C=C/CCC"],
	         't18:0' => ["4R-hydroxy-sphinganine", "C(O)C(O)CCCCCCCCCCCCCC"],
	         #'t18:1' => ["C(O)/C(O)=C/CCCCCCCCCCCCC"],
	         #'t18:2' => ["C(O)/C(O)=C/CCCCCCCC/C=C/CCC"],
	         't19:0' => ["4R-hydroxy-nonadecasphinganine", "C(O)C(O)CCCCCCCCCCCCCCC"],
	         #'t19:1' => ["C(O)/C(O)=C/CCCCCCCCCCCCCC"],
	         #'t19:2' => ["C(O)/C(O)=C/CCCCCCCCC/C=C/CCC"],
	         't20:0' => ["4R-hydroxy-eicosasphinganine", "C(O)C(O)CCCCCCCCCCCCCCCC"],
	         #'t20:1' => ["C(O)/C(O)=C/CCCCCCCCCCCCCCC"],
	         #'t20:2' => ["C(O)/C(O)=C/CCCCCCCCCC/C=C/CCC"],
	         'FMC-5' => {
	         	'd16:0' => ["hexadecasphinganine", "C(OC(C)=O)CCCCCCCCCCCCC"],
	         	'd16:1' => ["hexadecasphing-4-enine", 'C(OC(C)=O)/C=C/CCCCCCCCCCC'],
	         	'd16:2' => ["4E,8E-hexadecasphingdienine", 'C(OC(C)=O)\C=C\CC/C=C/CCCCCCC'],
	         	'd17:0' => ["heptadecasphinganine", "C(OC(C)=O)CCCCCCCCCCCCCC"],
	         	'd17:1' => ["heptadecasphing-4-enine", "C(OC(C)=O)/C=C/CCCCCCCCCCCC"],
	         	'd17:2' => ["4E,8E-heptadecasphingdienine", "C(OC(C)=O)/C=C/CC/C=C/CCCCCCCC"],
	         	'd18:0' => ["sphinganine", "C(OC(C)=O)CCCCCCCCCCCCCCC"],
	         	'd18:1' => ["sphing-4-enine", "C(OC(C)=O)/C=C/CCCCCCCCCCCCC"],
	         	'd18:2' => ["4E,8E-sphingdienine", "C(OC(C)=O)/C=C/CC/C=C/CCCCCCCCC"],
	         	'd19:0' => ["nonadecasphinganine", "C(OC(C)=O)CCCCCCCCCCCCCCCC"],
	         	'd19:1' => ["nonadecasphing-4-enine", "C(OC(C)=O)/C=C/CCCCCCCCCCCCCC"],
	         	'd19:2' => ["4E,8E-nonadecasphingadienine", "C(OC(C)=O)/C=C/CC/C=C/CCCCCCCCCC"],
	         	'd20:0' => ["eicosasphinganine", "C(OC(C)=O)CCCCCCCCCCCCCCCCC"],
	         	'd20:1' => ["eicosasphing-4-enine", "C(OC(C)=O)/C=C/CCCCCCCCCCCCCCC"],
	         	'd20:2' => ["4E,8E-eicosasphingdienine", "C(OC(C)=O)/C=C/CC/C=C/CCCCCCCCCCC"],
	         }
}


$units_nr={
			"1"=>'',
			"2"=>'di',
			"3"=>'tri',
			"4"=>'tetra'
		}


$head_groups={
				# head class, head group, (max) number of chains
				"CE"=>['O(R1)C1CCC2(C)C3CCC4(C)C(CCC4C3CC=C2C1)C(C)CCCC(C)C',1,"cholesteryl esters"],
				"CL"=>['OC(COP(O)(=O)OC[C@@H](CO(R1))O(R2))COP(O)(=O)OC[C@@H](CO(R3))O(R4)',4,"cardiolipins"],
				"1-MLCL"=>['OC(COP(O)(=O)OC[C@@H](CO(R1))O(R2))COP(O)(=O)OC[C@@H](CO(R3))O(R4)',4,"monolysocardiolipins"],
				"2-MLCL"=>['OC(COP(O)(=O)OC[C@@H](CO(R1))O(R2))COP(O)(=O)OC[C@@H](CO(R3))O(R4)',4,"monolysocardiolipins"],
				'GL'=>['O(R1)CC(CO(R3))O(R2)',3,"glycerolipids","sn-glycerol"],
				'MG'=>['O(R1)CC(CO(R3))O(R2)',1,"monoradylglycerolipids","sn-glycerol"],
				'DG'=>['O(R1)CC(CO(R3))O(R2)',2,"diradylglycerolipids","sn-glycerol"],
				'TG'=>['O(R1)CC(CO(R3))O(R2)',3,"triradylglycerolipids","sn-glycerol"],
				'PC'=>['C[N+](C)(C)CCOP(O)(=O)OCC(CO(R1))O(R2)',2,"glycerophosphocholines","sn-glycero-3-phosphocholine"],
				'PS'=>['NC(COP([O-])(=O)OC[C@@H](CO(R1))O(R2))C([O-])=O',2,"glycerophosphoserines","sn-glycero-3-phosphoserine"],
				'PE'=>['NCCOP(O)(=O)OC[C@@H](CO(R1))O(R2)',2,"glycerophosphoethanolamines","sn-glycero-3-phosphoethanolamine"],
				'PG'=>['OCC(O)COP(O)(=O)OCC(CO(R1))O(R2)',2,"glycerophosphoglycerols","sn-glycero-3-phospho-(1'-sn-glycerol)"],
				'PGP'=>['O[C@@H](COP(O)(O)=O)COP(O)(=O)OC[C@@H](CO(R1))O(R2)',2,"glycerophosphoglycerophosphates","sn-glycero-3-phospho-(1'-sn-glycerol-3'-phosphate)"],
				'PI'=>['O[C@H]1[C@H](O)[C@@H](O)[C@H](OP(O)(=O)OC[C@@H](CO(R1))O(R2))[C@H](O)[C@@H]1O',2,"glycerophosphoinositols","sn-glycero-3-phospho-(1'-myo-inositol)"],
				'PIP'=>['O[C@H]1[C@H](O)[C@@H](O)[C@H](OP(O)(=O)OC[C@@H](CO(R1))O(R2))[C@H](OP(O)(O)=O)[C@@H]1O',2,"glycerophosphoinositol phosphates"],
				'PPA'=>['OP(O)(=O)OP(O)(=O)OCC(CO(R1))O(R2)',2,"glyceropyrophosphates","-sn-glycero-3-pyrophosphate"],
				'PA'=>['OP(O)(=O)OCC(CO(R1))O(R2)',2,"glycerophosphates","sn-glycero-3-phosphate"],
				'CDP-DG'=>['NC1=NC(=O)N(C=C1)[C@@H]1O[C@H](COP(O)(=O)OP(O)(=O)OC[C@@H](CO(R1))O(R2))[C@@H](O)[C@H]1O',2,"CDP-glycerols","sn-glycero-3-cytidine-5'-diphosphate"],
				'PnC'=>['C[N+](C)(C)CCP(O)(=O)OCC(CO(R1))O(R2)',2,"glycerophosphonocholines","sn-glycero-3-phosphonocholine"],
				'PnE'=>['NCCP(O)(=O)OC[C@@H](CO(R1))O(R2)',2,"glycerophosphonoethanolamines","sn-glycero-3-phosphonoethanolamine"],
				"AC"=>['C[N+](C)(C)CC(O(R1))CC([O-])=O',1,"acylcarnitines","carnitines"],
        		"AG"=>['OC(=O)CN(R1)',1,'acylglycines','glycines'],
        		"PIP[3']"=>[2,"sn-glycero-3-phospho-(1'-myo-inositol-3'-phosphate)"],
				"PIP[4']"=>[2,"sn-glycero-3-phospho-(1'-myo-inositol-4'-phosphate)"],
				"PIP[5']"=>[2,"sn-glycero-3-phospho-(1'-myo-inositol-5'-phosphate)"],
				"PIP2[3',4']"=>[2,"sn-glycero-3-phospho-(1'-myo-inositol-3',4'-bisphosphate)"],
				"PIP2[3',5']"=>[2,"sn-glycero-3-phospho-(1'-myo-inositol-3',5'-bisphosphate)"],
				"PIP2[4',5']"=>[2,"sn-glycero-3-phospho-(1'-myo-inositol-4',5'-bisphosphate)"],
				"PIP3[3',4',5']"=>[2,"sn-glycero-3-phospho-(1'-myo-inositol-3',4',5'-trisphosphate)"],
				"PE-NMe"=>['C[NH2+]CCOP([O-])(=O)OCC(COC(=O)[R1])OC(=O)[R2]',2,"monomethylphosphatidylethanolamine"],
				"PE-NMe2"=>['C[N+](C)CCOP([O-])(=O)OCC(COC(=O)[R1])OC(=O)[R2]',2,"dimethylphosphatidylethanolamine"],
				"Lyso-PE"=>['[NH3]CCOP([O-])(=O)[O-]CC(O)[R2]COC([R1])=O',1,"lysophosphatidylethanolamine"],
				"Lyso-PC"=>['C[N](C)(C)CCOP([O-])(=[O-])OCC((O)[R2]COC([R1])=O',2,"lysophosphatidylcholine"],
				"Lyso-PA"=>['[H][C@@](O)([R2]COC([R1])(=O))COP(O)(O)=O',2,"lysophosphatidic acid"],
				"Lyso-PS"=>['[NH3]C(COP([O-])(=O)OCC(CO)[R2]OC([R1])=O)C([O-])=O',1,"lysophosphatidylserine"],
				"Lyso-PI"=>['OC1C(O)C(O)C(OP(O)(=O)OCC[R2]COC([R1])=O)C(O)C1O',1,"lysophosphatidylinositol"],
				"ESP8N"=>['CCCCCCCCC/C=C/CCCCC(O)C(CO)N([R1])[H]',1,"sphing-8-enine"],
				"ZSP8N"=>['CCCCCCCCC\C=C/CCCCC(O)C(CO)N([R1])[H]',1,"(Z)-sphing-8-enine"],
				"E4HSP8N"=>['CCCCCCCCC/C=C/CCCC(O)C(O)C(CO)N([R1])[H]',1,"(E)-4-hydroxysphing-8-enine"],
				"Z4HSP8N"=>['CCCCCCCCC/C=C/CCCC(O)C(O)C(CO)N([R1])[H]',1,"(Z)-4-hydroxysphing-8-enine"],
				"4E8ESPDN"=>['CCCCCCCCC/C=C/CC/C=C/C(O)C(CO)N([R1])[H]',1,"(4E,8E)-sphing-4,8-dienine"],
				"4E8ZSPDN"=>['CCCCCCCCC\C=C/CC/C=C/C(O)C(CO)N([R1])[H]',1,"(4E,8Z)-sphing-4,8-dienine"],


			# Addition of sphingolipids headgroups, these include part of the backbone structure (2C atoms from the right!)
			# Note that if you add more, please make sure stereochemistry is right.
				"FMC-5" => ["(R0)[C@@H](CO[C@@H]1O[C@H](COC(C)=O)[C@H](OC(C)=O)C(OC(C)=O)C1OC(C)=O)N(R1)",2, "fast-migrating-cerebrosides", "β-(2',3',4',6'-tetra-O-acetyl-galactosyl)-3-O-acetyl", "3-O-acetyl-###-2,3,4,6-tetra-O-acetyl-GalCer"],
				"CerP" => ["(R0)[C@@H](COP(O)(O)=O)N(R1)",2, "ceramide-phosphate", "phosphate", "ceramide-1-phosphate", "Cer1P"],
				"Cer" => ['(R0)[C@@H](CO)N(R1)',2,"ceramide", ""],
				"DHCer" => ["(R0)[C@@H](CO)N(R1)",2, "dihydroceramide", ""],
				"DHS" => ["(R0)[C@@H](CO)N(R1)", 2, "dihydrosphingosine", ""],
				"DHS-1-P" => ['(R0)[C@@H](COP(O)(O)=O)N(R1)', 2,"dihydrosphingosinephosphate", "phosphate"],
				"DHSM" => ["(R0)[C@@H](COP(=O)([O-])OCC[N+](C)(C)C)N(R1)", 2, "dihydrosphingomyelin", "phosphocholine"],
				"GlcCer" => ["(R0)[C@@H](CO[C@@H]1O[C@H](CO)[C@@H](O)C(O)C1O)N(R1)", 2, "glucosylceramide", "β-glucosyl"],
				"KDHS" => ["(R0)[C@@H](CO)N(R1)", 2, "ketosphinganine", ""],
				"PE-Cer" => ["(R0)[C@@H](COP(O)(=O)OCCN)N(R1)", 2, "ceramide-1-phosphoethanolamine", "phosphoethanolamine"],
				"PHC" => ["(R0)[C@@H](CO)N(R1)", 2, "phytoceramide", ""],
				"PHS" => ["(R0)[C@@H](CO)N(R1)", 2, "phytosphingosine", ""],
				"PI-Cer" => ["(R0)[C@@H](COP(O)(=O)O[C@@H]1C(O)[C@H](O)C(O)C(O)C1O)N(R1)", 2, "cer-phosphoinositol", "phospho-(1'-myo-inositol)"],
				"S1P" => ["(R0)[C@@H](COP(O)(O)=O)N(R1)", 2, "sphingosine-1-phosphate", "1-phosphate"],
				"SGalCer" => ["(R0)[C@@H](CO[C@@H]1O[C@H](CO)[C@H](O)C(OS(O)(=O)=O)C1O)N(R1)", 2, "galactosylceramide-sulfate", "(3'-sulfo)-β-galactosyl"],
				"SM" => ["(R0)[C@@H](COP(=O)([O-])OCC[N+](C)(C)C)N(R1)", 2, "sphingomyelin", "phosphocholine"],
				"SP" => ['(R0)[C@@H](CO)N(R1)', 2,"sphingosine", ""], 
				"SPN" => ['(R0)[C@@H](CO)N(R1)',2,"sphingosine", ""], # same as SP
				"SPC" => ["(R0)[C@@H](COP(=O)([O-])OCC[N+](C)(C)C)N(R1)", 2, "sphingosine-phosphocholine", "phosphocholine"],
				"LacCer" => ["(R0)[C@@H](CO[C@@H]1OC(CO)[C@@H](O[C@@H]2OC(CO)[C@H](O)[C@H](O)C2O)[C@H](O)C1O)N(R1)", 2, "lactosylceramide", "β-lactosyl"],
				"CB" => ['(R0)[C@@H](CO[C@H]1O[C@@H](CO)[C@H](O)[C@@H](O)[C@@H]1O)N(R1)',2,"cerebrosides", "β-D-Glucopyranosyloxy"],
				"GIPC" => ['(R0)[C@@H](COP(=O)(O)OC3C(O)C(O)C(OC2OC(C(=O)O)C(OC1CC(CO)C(O)C(O)C1O)C(O)C2O)C(O)C3O)N(R1)',2,"glucosylinositolphosphoceramide", "glucosylinositolphosphate"], # couldn't find the stereochemistry for the smiles!
				"NeuAca2-3Galb1-4Glcb-Cer" => ['(R0)[C@@H](CO[C@@H]1O[C@H](CO)[C@@H](O[C@@H]2O[C@H](CO)[C@H](O)C(O[C@@]3(CC(O)[C@@H](NC(C)=O)[C@H](O3)[C@H](O)[C@@H](O)CO)C(O)=O)C2O)C(O)C1O)N(R1)', 2, 'NeuAca2-3Galb1-4Glcb-Cer', 'beta-GM3'],
				"GM3-Cer" => ['','','NeuAca2-3Galb1-4Glcb-Cer','beta-GM3'], # this will point to 'NeuAca2-3Galb1-4Glcb-Cer'
				"NeuAca2-3Galb-Cer" => ['(R0)[C@@H](CO[C@@H]1OC(CO)[C@@H](O[C@@H]2OC(CO)[C@H](O)[C@H](O[C@@]3(CC(O)[C@@H](NC(C)=O)C(O3)[C@H](O)[C@H](O)CO)C(O)=O)C2O)[C@H](O)C1O)N(R1)', 2, 'NeuAca2-3Galb-Cer', 'beta-GM4'],
				"GM4-Cer" => ['','','NeuAca2-3Galb-Cer','beta-GM4'], # this will point to 'NeuAca2-3Galb-Cer'
}


def find_head_group(abbrev)
	return abbrev.split("(")[0]
end

def find_side_chains(abbrev)
	side_chains=Array.new
	if not (abbrev[0..1].include?("CE") or abbrev[0..1].include?("AC") or abbrev[0..1].include?("AG"))
		s=abbrev.split("/")
		side_chains<<s[0].gsub("#{s[0].split("(")[0]}(",'')
		if s[1...-1].length>0
			side_chains=side_chains+s[1...-1]
			side_chains<<s[-1][0...-1]
			#$stderr.puts "s[-1][0...-1]=#{s[-1][0...-1]}"
		else
			side_chains<<s[-1][0...-1]
		end
	else
		side_chains<< abbrev[3...-1]
	end
	return side_chains
end

def find_nr_of_chains(side_chains)
	return	(side_chains-["0/0"]).length
end
