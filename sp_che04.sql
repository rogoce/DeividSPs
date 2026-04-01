-- Reporte de las Comisiones por Corredor - Totales
-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - d_cheq_sp_che04_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che04;

CREATE PROCEDURE sp_che04(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha_desde DATE, a_fecha_hasta DATE, a_verif_tipo_pago SMALLINT DEFAULT 0) 
RETURNING   DEC(16,2),	-- Monto
			DEC(16,2),	-- Prima
			DEC(16,2),	-- Comision
			CHAR(50),   -- Agente
			CHAR(50),	-- Compania
			DEC(16,2),	-- Vida
			DEC(16,2),	-- Danos
			DEC(16,2),	-- Fianzas
			DEC(16,2),
			CHAR(10);   -- Licencia

DEFINE v_nombre_agt   CHAR(50);
DEFINE v_monto        DEC(16,2);
DEFINE v_prima        DEC(16,2);
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_cia   CHAR(50);
DEFINE v_no_licencia  CHAR(10);
DEFINE v_monto_vida   DEC(16,2);
DEFINE v_monto_danos  DEC(16,2);
DEFINE v_monto_fianza DEC(16,2);
DEFINE v_arrastre	  DEC(16,2);
DEFINE _cod_agente    CHAR(5);
DEFINE _fecha_ult_comis DATE;  
DEFINE _tipo_pago     SMALLINT; 
DEFINE _tipo_agente   CHAR(1);  
DEFINE v_comision2    DEC(16,2);
define _no_recibo		char(10);
define v_no_recibo		char(10);
define _fecha_recibo	date;
define _no_poliza		char(10);
define _no_documento	char(21);
define _cnt_existe		smallint;
define _comision_adelanto	dec(16,2);
define _no_requis		char(10);
define _tipo_requis     char(1);
define _mto_bono        decimal(16,2);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET  v_nombre_cia = sp_sis01(a_compania); 

--DROP TABLE tmp_agente;

CALL sp_che02(
a_compania, 
a_sucursal,
a_fecha_desde,
a_fecha_hasta,
0,
a_verif_tipo_pago
);

--SET DEBUG FILE TO "sp_che04.trc";
--TRACE ON;

foreach
	select a.cod_agente,
		   a.no_recibo,
		   a.no_poliza,
		   a.no_documento,
		   a.fecha
	  into _cod_agente,
		   v_no_recibo,
		   _no_poliza,
		   _no_documento,
		   _fecha_recibo
	  from tmp_agente a
	 where a.seleccionado = 1

  {if _cod_agente = "00879" then
     trace on;
  else
     trace off;
  end if}
  
let  _cod_agente = _cod_agente; 
let  v_no_recibo = v_no_recibo; 
let  _no_poliza = _no_poliza ;
let  _no_documento = _no_documento ;
let  _fecha_recibo = _fecha_recibo;
let _mto_bono      = 0;

  {	select a.cod_agente,
		   a.no_recibo,
		   a.no_poliza,
		   a.no_documento,
		   a.fecha
	  into _cod_agente,
		   v_no_recibo,
		   _no_poliza,
		   _no_documento,
		   _fecha_recibo
	  from tmp_agente a,agtagent b
	 where a.cod_agente = b.cod_agente
	  --and (b.adelanto_comis = 1 or b.cod_agente = '00692')
	   and a.seleccionado = 1 }

-- Adelanto de Comision -- CASO: 15971 USER: ZULEYKA PC: CMCONT06

{    let _cnt_existe = 0;

	select count(*)
	  into _cnt_existe
	  from cobadeco
	 where no_documento = _no_documento
	   and cod_agente	= _cod_agente;
	
	if _cnt_existe > 0  then 
		if _no_poliza <> '00000' then
			select comision_adelanto,
				   no_recibo
			  into _comision_adelanto,
				   _no_recibo
			  from cobadeco
			 where cod_agente	= _cod_agente
			   and no_documento = _no_documento;

			if v_no_recibo = _no_recibo then
				let v_comision	= _comision_adelanto;
			else
				let v_comision	= 0.00;
			end if
		end if

		update tmp_agente
		   set comision     = v_comision
		 where cod_agente	= _cod_agente
		   and no_poliza	= _no_poliza
		   and no_recibo	= v_no_recibo
		   and fecha		= _fecha_recibo;
	end if

	}
	
	let _cnt_existe = 0;
-- CASO: 33614 USER: ZULEYKA Ya no habrá más adelanto Amado 22/01/2020
{ 
if _cod_agente = "00628" then 
	   
   	if _no_poliza <> '00000' then
		select count(*)
		  into _cnt_existe
		  from cobadeco																			 
		 where cod_agente	= _cod_agente
		   and no_documento = _no_documento;

		if _cnt_existe is null then
			let _cnt_existe = 0;
		end if

		if _cnt_existe <> 0 or _no_documento in ('0214-03842-01','0212-02539-01','1808-00589-01') then
			select comision_adelanto,
				   no_recibo
			  into _comision_adelanto,
			  	   _no_recibo
			  from cobadeco
			 where cod_agente	= _cod_agente
			   and no_documento = _no_documento;
			   
			if v_no_recibo = _no_recibo then
				let v_comision			= _comision_adelanto;
			else
				let v_comision			= 0.00; 
			end if
			
			update tmp_agente
			   set comision = v_comision
			 where cod_agente	= _cod_agente
			   and no_poliza	= _no_poliza
			   and no_recibo	= v_no_recibo
			   and fecha		= _fecha_recibo;
		
		else
			if _no_documento <> '0213-00946-04' then
				select count(*)
				  into _cnt_existe
				  from cobadecoh
				 where no_documento = _no_documento 
				   and cod_agente	= _cod_agente
				   and fecha >= _fecha_recibo
				   and poliza_cancelada = 1;

				if _cnt_existe > 0 then
					select comision_adelanto,
						   no_recibo
					  into _comision_adelanto,
						   _no_recibo
					  from cobadecoh
					 where cod_agente	= _cod_agente
					   and no_documento = _no_documento
					   and fecha >= _fecha_recibo;

					if v_no_recibo = _no_recibo then
						let v_comision			= _comision_adelanto;
					else
						let v_comision			= 0.00; 
					end if
					
					update tmp_agente
					   set comision = v_comision
					 where cod_agente	= _cod_agente
					   and no_poliza	= _no_poliza
					   and no_recibo	= v_no_recibo
					   and fecha		= _fecha_recibo;
				end if
			end if
		end if
	end if 	
end if	
}
end foreach
--TRACE Off;
FOREACH
 SELECT	SUM(monto),
		SUM(prima),
		SUM(comision),
		SUM(monto_vida),
		SUM(monto_danos),
		SUM(monto_fianza),
		nombre,
		no_licencia,
		cod_agente
   INTO	v_monto,
		v_prima,
		v_comision,
		v_monto_vida,
		v_monto_danos,
		v_monto_fianza,
		v_nombre_agt,
		v_no_licencia,
		_cod_agente
   FROM	tmp_agente
  GROUP BY nombre, no_licencia, cod_agente
  ORDER BY nombre, no_licencia, cod_agente
  
		select sum(comision)
		  into _mto_bono
		  from chqcomis
		 where cod_agente = _cod_agente
		   and fecha_desde = a_fecha_desde
		   and fecha_hasta = a_fecha_hasta
		   and bono_salud  = 1;

		if _mto_bono is null then
			let _mto_bono = 0;
		end if
        let v_comision = v_comision + _mto_bono;		
    
	{if _cod_agente = "00879" then
		trace on;
	else
		trace off;
	end if	 }

	LET v_arrastre = 0;

	if a_verif_tipo_pago <> 0 then

		select sum(monto)
		  into v_arrastre
		  from agtsalhi
		 where cod_agente = _cod_agente
		   and fecha_al = a_fecha_hasta;
		   
		SELECT fecha_ult_comis,
			   tipo_pago,
			   tipo_agente
		  INTO _fecha_ult_comis,
			   _tipo_pago,
			   _tipo_agente
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		IF a_verif_tipo_pago <> 0 THEN
		   let _no_requis = null;
           foreach
			   select no_requis
			     into _no_requis
				 from chqcomis
			    where cod_agente = _cod_agente
				  and fecha_desde = a_fecha_desde
				  and fecha_hasta = a_fecha_hasta

               exit foreach;
			end foreach

            if _no_requis is not null and trim(_no_requis) <> "" then
			   select tipo_requis
			     into _tipo_requis
				 from chqchmae
				where no_requis = _no_requis;

                if _tipo_requis = "A" then
					let _tipo_pago = 1;
				else
					let _tipo_pago = 2;
				end if
			end if   

		    IF _tipo_agente = "O" THEN
	 			CONTINUE FOREACH;
			END IF
			IF _tipo_pago <> a_verif_tipo_pago THEN
				CONTINUE FOREACH;
			END IF
		END IF
      

		IF _fecha_ult_comis IS NOT NULL THEN
			IF _fecha_ult_comis < a_fecha_hasta THEN
				CONTINUE FOREACH;
			END IF
		ELSE
			CONTINUE FOREACH;
		END IF 
	END IF

  IF v_arrastre IS NULL THEN
  	LET v_arrastre = 0;
  END IF

  LET v_comision = v_comision + v_arrastre;

  IF a_verif_tipo_pago = 2 THEN
  	IF v_comision <= 100 THEN
		CONTINUE FOREACH;
  	END IF
  ELIF a_verif_tipo_pago = 1 THEN
  	IF v_comision <= 0 THEN
		CONTINUE FOREACH;
  	END IF
  END IF 
  
	RETURN  v_monto,
			v_prima,
			v_comision,
			v_nombre_agt,
			v_nombre_cia,
			v_monto_vida,
			v_monto_danos,
			v_monto_fianza,
			v_arrastre,
			v_no_licencia
			WITH RESUME;
	
END FOREACH

DROP TABLE tmp_agente;

END PROCEDURE;