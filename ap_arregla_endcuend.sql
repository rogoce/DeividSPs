-- Adiciona registros en endcuend de polizas rehabilitadas incendio y multiriesgos
DROP PROCEDURE ap_arregla_endcuend;
CREATE PROCEDURE ap_arregla_endcuend()
RETURNING integer 		as error_num,
		  VARCHAR(50)   as desc_err;

DEFINE _error 				smallint; 
DEFINE as_no_poliza			CHAR(10);
DEFINE as_no_endoso			CHAR(5);
DEFINE as_no_unidad			CHAR(5);
DEFINE as_cod_ramo		    CHAR(3);
DEFINE ls_cod_cober_reas    CHAR(3);
DEFINE ls_cod_ubica    		CHAR(3);
DEFINE li_cant, li_ramo_sis SMALLINT;


DEFINE _no_documento        CHAR(20);
DEFINE ld_suma_asegurada_inc,ld_prima_inc,ld_suma_asegurada_ter,ld_prima_ter DEC(16,2);
DEFINE ld_suma_incendio,ld_suma_terremoto DEC(16,2);


--set debug file to "ap_arregla_endcuend.trc";
--trace on;

set isolation to dirty read;
BEGIN
ON EXCEPTION SET _error 
 	RETURN _error, "Error al Actualizar"; 
END EXCEPTION 

LET ld_suma_asegurada_inc = 0;
LET ld_prima_inc = 0;
LET ld_suma_asegurada_ter = 0;
LET ld_prima_ter = 0;
LET ld_suma_incendio = 0;
LET ld_suma_terremoto = 0;
LET ls_cod_ubica = NULL;
LET li_cant = 0;

FOREACH
	select a.no_poliza,
	       a.no_endoso,
		   b.no_unidad
	  into as_no_poliza,
	       as_no_endoso,
      	   as_no_unidad
      from endedmae a, endeduni b
     where a.no_poliza = b.no_poliza
       and a.no_endoso = b.no_endoso
       and a.no_factura in (
'01-2937041',
'01-2937076',
'01-2938935',
'01-2939230',
'01-2944793',
'01-2943775',
'01-2945349',
'07-89017',
'01-2945847',
'01-2947926',
'01-2948015',
'01-2948380',
'01-2952858',
'01-2953768',
'01-2953770',
'01-2954446',
'01-2955605',
'01-2956191',
'01-2957315',
'10-83962',
'10-83965',
'01-2957428',
'01-2962395',
'01-2962394',
'01-2962748',
'01-2962746',
'05-83438',
'01-2963324',
'01-2963327',
'10-84410',
'01-2963773',
'01-2965189',
'01-2966954',
'03-234976',
'1358616',
'01-2972597',
'01-2973030',
'02-115952',
'11-67279',
'01-2980389',
'01-2980331',
'01-2980330',
'01-2980749',
'01-2980812',
'01-2981250',
'01-2982803',
'01-2982801',
'01-2982814',
'01-2982815',
'01-2983254',
'03-237320',
'01-2987488',
'02-116280',
'01-2988801',
'01-2988798',
'01-2991489',
'01-2991488',
'03-238356',
'03-238355',
'03-238375',
'01-2996682',
'05-85024',
'01-2997482',
'01-2997484',
'01-2998827',
'01-2998826',
'01-2999248',
'03-238930',
'03-238929',
'02-116699',
'01-3000620',
'01-3000904',
'03-239350',
'01-3007109',
'01-3007550',
'01-3008559',
'01-3009001',
'07-92320',
'07-92321',
'03-240514',
'01-3011181',
'10-88466',
'01-3011207',
'01-3011718',
'01-3011884',
'01-3011908',
'01-3011909',
'01-3015787',
'01-3018480'
       )	   
	  
	Select count(*) 
	  Into li_cant 
	  From endcuend
	 Where no_poliza   = as_no_poliza
		And no_endoso  = as_no_endoso
		And no_unidad  = as_no_unidad; 
	 
    select cod_ramo
      into as_cod_ramo
      from emipomae
     where no_poliza = as_no_poliza;	  
 
	if as_cod_ramo in ('001','003') then 				
			LET ld_suma_asegurada_inc = 0;
			LET ld_prima_inc = 0;
			LET ld_suma_asegurada_ter = 0;
			LET ld_prima_ter = 0;
						
			Select SUM(emifacon.suma_asegurada),
				   SUM(emifacon.prima)
			  Into ld_suma_asegurada_inc,
				   ld_prima_inc
			  From emifacon
			 Where emifacon.no_poliza  	 = as_no_poliza
				And emifacon.no_endoso   = as_no_endoso
				And emifacon.no_unidad 	 = as_no_unidad
				And emifacon.cod_cober_reas in (
					Select cod_cober_reas
			          From reacobre
			         Where cod_ramo  	 = as_cod_ramo
				      And es_terremoto = 0);
		
			
			Select SUM(emifacon.suma_asegurada),
				   SUM(emifacon.prima)
			  Into ld_suma_asegurada_ter,
				   ld_prima_ter
			  From emifacon
			 Where emifacon.no_poliza  	 = as_no_poliza
				And emifacon.no_endoso   = as_no_endoso
				And emifacon.no_unidad 	 = as_no_unidad
				And emifacon.cod_cober_reas in (
					Select cod_cober_reas
			          From reacobre
			         Where cod_ramo  	 = as_cod_ramo
				      And es_terremoto = 1);				
		
			If ld_suma_asegurada_inc IS NULL Then
				let ld_suma_asegurada_inc = 0;
			End If
			If ld_suma_asegurada_ter IS NULL Then
				let ld_suma_asegurada_ter = 0;
			End IF	
			If	ld_prima_inc IS NULL Then
				let ld_prima_inc = 0;
			End If	
			If	ld_prima_ter IS NULL Then
				let ld_prima_ter = 0;
			End If								 

			Select endcuend.cod_ubica
			  Into ls_cod_ubica
			  From endcuend
			 Where endcuend.no_poliza  	 = as_no_poliza
				And endcuend.no_endoso   = as_no_endoso
				And endcuend.no_unidad   = as_no_unidad;
			 
			let ls_cod_ubica = TRIM(ls_cod_ubica);	

			If li_cant = 0 Then
				Select emicupol.cod_ubica
				  Into ls_cod_ubica
				  From emicupol
				 Where emicupol.no_poliza  	 = as_no_poliza
					And emicupol.no_unidad   = as_no_unidad;
					
				let ls_cod_ubica = TRIM(ls_cod_ubica);
				
				If ls_cod_ubica is null Then
					Return 1, 'Avisar a cómputo, para verificar la ubicación...';				  
				End If	

				Insert Into endcuend (
					no_poliza, 
					no_endoso, 
					no_unidad, 
					cod_ubica, 
					suma_incendio,
					suma_terremoto, 
					prima_incendio, 
					prima_terremoto, 
					opcion)
				Values (
					as_no_poliza, 
					as_no_endoso, 
					as_no_unidad, 
					ls_cod_ubica, 
					ld_suma_asegurada_inc, 
					ld_suma_asegurada_ter,
					ld_prima_inc, 
					ld_prima_ter, 
					2);

			Else
				Update endcuend
					Set suma_incendio   = ld_suma_asegurada_inc,
						suma_terremoto  = ld_suma_asegurada_ter,
						 prima_incendio  = ld_prima_inc,
						 prima_terremoto = ld_prima_ter
				 Where endcuend.no_poliza = as_no_poliza
					And endcuend.no_endoso = as_no_endoso
					And endcuend.no_unidad = as_no_unidad
					And endcuend.cod_ubica = ls_cod_ubica;
			End If
	End if	
END FOREACH
Return 0, "Exito";
END 

END PROCEDURE; 