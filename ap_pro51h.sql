-- deducibles
-- Creado       : 13/05/2009
-- Autor: Armando Moreno M.
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE ap_pro51h;

CREATE PROCEDURE "informix".ap_pro51h(a_poliza CHAR(10), a_producto CHAR(5), a_ramo CHAR(3), a_unidad CHAR(5), a_cobertura CHAR(5), a_marca CHAR(5), a_suma DECIMAL(16,2), a_tarifa DECIMAL(16,2), a_uso_auto CHAR(1))
RETURNING DECIMAL(16,2);  -- _ld_deducible

--**********************DECLARACION DE VARIABLE***********************--

DEFINE _ld_tipo_deduc          INTEGER;
DEFINE _ls_tipo_rec_com        CHAR(1);
DEFINE _ls_tipo_rec_col        CHAR(1);
DEFINE _ld_existe              INTEGER;

DEFINE _ld_rec_ded_col   DECIMAL(16,2);
DEFINE _ld_rec_ded_com   DECIMAL(16,2);
DEFINE _ld_deducible     DECIMAL(16,2);
DEFINE _ld_ded_min       DECIMAL(16,2);
DEFINE _ld_deduc_anter   DECIMAL(16,2);
DEFINE _ld_suma          DECIMAL(16,2);
DEFINE _ld_tarifa        DECIMAL(16,2);
DEFINE _ld_prima_act     DECIMAL(16,2);
DEFINE ld_ded_rec        DECIMAL(16,2);
DEFINE ls_cod_cob_ded    char(5);
DEFINE ld_porcded_r      decimal(16,2);
DEFINE _porc_b_exp_max,_suma_aseg_max DECIMAL(16,2);
DEFINE _li_tipo_ded		smallint;
DEFINE _ded_pro			DECIMAL(16,2);
DEFINE ld_porc          DECIMAL(16,2);
define ld_ded_min       DECIMAL(16,2);
define li_anos          integer;
DEFINE _opcion            char(1);
define _cnt_casco         smallint;
define _descuento, _recargo dec(16,2);
define _ld_deduc_rd     DECIMAL(16,2); 
DEFINE ld_porc_rd          DECIMAL(16,2); 
define _cod_subramo 	CHAR(3); 
define ld_des_ded_a,ld_rec_pri_a,ld_des_ded_b,ld_rec_pri_b,ld_des_ded_c,ld_rec_pri_c DECIMAL(5,2); 

SET ISOLATION TO DIRTY READ;

--********************INICIALIZACION DE VARIABLES*********************--
--if a_poliza = '2833951' then
set debug file to "ap_pro51h.trc"; 
trace on;    
--end if 

LET _ld_existe      = 0;
LET _ld_suma        = a_suma;
LET _ld_tarifa      = a_tarifa;
LET _ld_deducible   = 00.00;
LET _ld_prima_act   = 00.00;
LET _ld_deduc_rd    = 00.00;

let ld_porcded_r    = 0;
let ld_ded_rec      = 0;
LET _li_tipo_ded    = 0;
LET _ded_pro        = 0;

let ld_des_ded_a    = 0;
let ld_rec_pri_a    = 0;
let ld_des_ded_b    = 0;
let ld_rec_pri_b    = 0;
let ld_des_ded_c    = 0;
let ld_rec_pri_c    = 0;


--*******************VERFIFICA SI LA MARCA EXISTE*********************--
SELECT cod_subramo
  INTO _cod_subramo
  FROM emipomae
 WHERE no_poliza = a_poliza;

SELECT count(*)
  INTO _ld_existe
  FROM emirecmarc
 WHERE cod_marca = a_marca;

select tipo_deducible,
       deducible,
	   deducible_min
  into _li_tipo_ded,
       _ded_pro,
	   ld_ded_min
  from prdcobpd
 where cod_producto  = a_producto
   and cod_cobertura = a_cobertura;
   
--Nuevos calculos al deducible sacados de la tabla prdcores1 ALTAGAMA, Amado 25/10/2018
If a_ramo = '002' and _cod_subramo = '001' then 
	call sp_rwf150(a_cobertura, a_suma) returning ld_des_ded_a,ld_rec_pri_a,ld_des_ded_b,ld_rec_pri_b,ld_des_ded_c,ld_rec_pri_c;
End If

IF a_uso_auto = "P" THEN
   --Colision
    IF a_cobertura IN ("00119", "00121", "01307") THEN
      LET _ld_prima_act = sp_pro51g(a_poliza, a_producto, a_ramo, a_unidad, a_cobertura, a_suma);

	    IF _li_tipo_ded = 4 then

			let ld_porc = _ded_pro / 100;

			LET _ld_deducible = Trunc((_ld_prima_act * ld_porc), 0);

	    elif _li_tipo_ded = 6 then
            select ano_tarifa 
			  into li_anos 
			  from emiauto  
			 where no_poliza = a_poliza 
			   and no_unidad = a_unidad;

 		  {  select a.ano_auto
			  into li_anos
			  from emivehic a, emiauto b
			 where a.no_motor = b.no_motor
			   and b.no_poliza = a_poliza
			   and b.no_unidad = a_unidad;}

			if li_anos < 1 then
				let li_anos = 1;
			end if
								
			let li_anos = li_anos - 1;
			
			let li_anos = 6;
				
			select deducible, deducible_min
			  into _ded_pro, ld_ded_min
			  from prdcobrd
			 where cod_producto  = a_producto
			   and cod_cobertura = a_cobertura
			   and renglon       = li_anos;
				
			If _ded_pro is null Then
			   let	_ded_pro = 0.00;
			End If

			let ld_porc = _ded_pro / 100; 
						
			LET _ld_deducible = Trunc((_ld_prima_act * ld_porc), 0);
	    elif _li_tipo_ded = 3	then

			  select deducible,
					 deducible_min
				into _ld_deducible,
					 _ld_ded_min
				from prdcobrd
			   where cod_producto  = a_producto
				 and cod_cobertura = a_cobertura
				 and a_suma between rango1 and rango2;
	    else
			let ld_porc = 25 / 100;
			LET _ld_deducible = Trunc((_ld_prima_act * ld_porc), 0);
	    end if


	  IF _ld_deducible < ld_ded_min THEN
		  LET _ld_deducible = ld_ded_min;
	  END IF
    END IF
   --Comprensivo
    IF a_cobertura IN ("00118", "00606", "00120", "00103", "01306", "01308", "01300") THEN
	
	  IF a_ramo = '002' THEN
		LET _ld_prima_act = sp_pro51g(a_poliza, a_producto, a_ramo, a_unidad, "00118", a_suma);
	  ELIF a_ramo = '023' THEN
		LET _ld_prima_act = sp_pro51g(a_poliza, a_producto, a_ramo, a_unidad, "01306", a_suma);
	  END IF
	  
	  LET _ld_deducible  = round(_ld_prima_act,0);
	  
	  IF  _ld_existe = 0 THEN
		   	IF _ld_deducible < ld_ded_min THEN
			   LET _ld_deducible = ld_ded_min;
			END IF
   
		   {	IF _ld_deducible < 150.00 THEN
			   LET _ld_deducible = 150.00;
			END IF}
	  END IF
    END IF

    IF a_cobertura NOT IN ("00118", "00606", "00119", "00121", "00120", "00103", "01307", "01306", "01308", "01300") THEN
	  SELECT d.deducible_min,
             d.tipo_deducible,
             d.deducible
        INTO _ld_ded_min,
             _ld_tipo_deduc,
             _ld_deducible
	   	FROM prdcobpd d,
             prdcober c
	   WHERE d.cod_cobertura = c.cod_cobertura
         AND c.cod_ramo      = a_ramo
         AND d.cod_producto  = a_producto
         AND c.cod_cobertura = a_cobertura;

   	  	IF _ld_deducible IS NULL THEN
      	   LET _ld_deducible = 00.00;
   	  	END IF

   	  IF _ld_tipo_deduc = 1 THEN --Fijo

   	  ELIF  _ld_tipo_deduc = 2 THEN --%suma
     	   	LET _ld_deducible = _ld_suma * _ld_deducible / 100;
   	  ELIF  _ld_tipo_deduc = 3 THEN --Por Rango
   	  ELIF  _ld_tipo_deduc = 4 THEN --Prima Anual 
            LET _ld_deducible = _ld_tarifa * _ld_deducible / 100;
   	  END IF

   	  IF _ld_ded_min > 0  AND _ld_deducible < _ld_ded_min THEN
	     LET _ld_deducible = _ld_ded_min;
   	  END IF
	  
    END IF
END IF

IF a_uso_auto = "C" THEN  --si es comercial segun tarifa
   
   SELECT d.deducible_min,
          d.tipo_deducible,
          d.deducible
     INTO _ld_ded_min,
          _ld_tipo_deduc,
          _ld_deducible
     FROM prdcobpd d,
          prdcober c
    WHERE d.cod_cobertura = c.cod_cobertura
      AND c.cod_ramo      = a_ramo
      AND d.cod_producto  = a_producto
      AND c.cod_cobertura = a_cobertura;

    IF _ld_deducible IS NULL THEN
      LET _ld_deducible = 00.00;
    END IF

    IF _ld_tipo_deduc = 1 THEN --Fijo
    ELIF  _ld_tipo_deduc = 2 THEN --%suma
     LET _ld_deducible = _ld_suma * _ld_deducible / 100;
    ELIF  _ld_tipo_deduc = 3 THEN --Por Rango

		  select deducible,
		         deducible_min
		    into _ld_deducible,
		      	 _ld_ded_min
		    from prdcobrd
		   where cod_producto  = a_producto
		     and cod_cobertura = a_cobertura
		     and a_suma between rango1 and rango2;

    ELIF  _ld_tipo_deduc = 4 THEN --Prima Anual 
     LET _ld_deducible = _ld_tarifa * _ld_deducible / 100;
    END IF

    IF _ld_ded_min > 0  AND _ld_deducible < _ld_ded_min THEN
	  LET _ld_deducible = _ld_ded_min;
    END IF
   
END IF

IF a_cobertura IN ("00118", "00606", "00119", "00121") AND _ld_existe > 0 and a_uso_auto = "P" THEN
   SELECT tipo_rec_compr,
          rec_compr,
     	  tipo_rec_colisi,
     	  rec_colision
     INTO _ls_tipo_rec_com,
          _ld_rec_ded_com,
       	  _ls_tipo_rec_col,
       	  _ld_rec_ded_col
     FROM emirecmarc
    WHERE cod_marca = a_marca;

   IF a_cobertura IN ("00118", "00606") THEN --COMPRENSIVO

	  IF _ls_tipo_rec_com   = 1 THEN --Valor
	 	 LET _ld_deducible  = _ld_deducible +  _ld_rec_ded_com;
      ELIF _ls_tipo_rec_com = 2 THEN --Porcentaje
	 	 LET _ld_deducible  = _ld_deducible + (_ld_deducible * (_ld_rec_ded_com/100));
      END IF

      IF _ld_deducible < 150.00 THEN
	 	 lET _ld_deducible = 150.00;
      END IF

   END IF

   IF a_cobertura IN ("00119", "00121") THEN --COLISION

      IF _ls_tipo_rec_col    = 1 THEN --Valor
	  	 LET _ld_deducible   =_ld_deducible + _ld_rec_ded_col;
      ELIF _ls_tipo_rec_col  = 2 THEN --Porcentaje
	 	 LET _ld_deducible   = _ld_deducible + (_ld_deducible * (_ld_rec_ded_col/100));
      END IF

	  IF _ld_deducible < 150.00 THEN
	 	 lET _ld_deducible = 150.00;
      END IF

   END IF

END IF

--Nuevos calculos al deducible sacados de la tabla emirecmar, Armando 19/03/2014
Call sp_sis193(a_poliza,a_unidad,a_cobertura) RETURNING ls_cod_cob_ded,ld_porcded_r,_porc_b_exp_max,_suma_aseg_max;

if (ls_cod_cob_ded = a_cobertura) and ld_porcded_r > 0 then
   let _ld_deducible = _ld_deducible + (_ld_deducible * ld_porcded_r / 100);
end if

--Nuevos calculos al deducible sacados de la tabla prdcores, Armando 19/03/2014
Call sp_sis192(a_cobertura,a_suma) RETURNING ld_ded_rec,ls_cod_cob_ded,ld_porcded_r;

if ((ls_cod_cob_ded = a_cobertura) and  ld_porcded_r > 0) and ((a_ramo = '002' and _cod_subramo <> '001') or a_ramo <> '002') then
	let _ld_deducible = ld_ded_rec;
end if

-- Calculo por opcion A, B o C
if a_ramo = '002' then
	select count(*) 
	  into _cnt_casco
	  from prdcober a, reacobre b
	 where a.cod_cober_reas = b.cod_cober_reas
	   and b.nombre like '%CASCO%'
	   and a.cod_cobertura = a_cobertura;
	   
	if _cnt_casco > 0 then
		select opcion
		  into _opcion
		  from emiauto 
		 where no_poliza = a_poliza
		   and no_unidad = a_unidad;
		   
		if _cod_subramo = '001' then
			if _opcion = "A" or _opcion is null or trim(_opcion) = "" then
				let _ld_deducible = _ld_deducible - _ld_deducible * ld_des_ded_a / 100;
			elif _opcion = "B" then
				let _ld_deducible = _ld_deducible - _ld_deducible * ld_des_ded_b / 100;
			elif _opcion = "C" then
				let _ld_deducible = _ld_deducible - _ld_deducible * ld_des_ded_c / 100;
			end if
		end if
	
		call sp_pro603(a_poliza, a_producto, _opcion) returning _descuento, _recargo;
		
		let _ld_deducible = _ld_deducible + (_ld_deducible * _recargo / 100);
	end if
end if


RETURN trunc(_ld_deducible,0);

END PROCEDURE;
