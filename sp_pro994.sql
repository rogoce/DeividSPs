-- Pool impresion de informe de excepciones diaria
-- Creado : 05/05/2010 - Autor: Henry Giron.
-- SIS v.2.0 - d_prod_sp_pro994_dw1 - DEIVID, S.A.
--CREATE PROCEDURE "informix".sp_pro994(a_sucursal char(3), a_mes smallint, a_codramo char(255))   -- Gladys, 20/07/2010

DROP PROCEDURE sp_pro994;
CREATE PROCEDURE "informix".sp_pro994(a_sucursal char(3), a_desde date, a_hasta date, a_codramo char(255))
returning varchar(50),	 -- n_corredor
		  char(10),		 -- no_poliza
		  char(8),		 -- user_added
		  char(3),       -- cod_no_renov
		  char(20),		 -- no_documento
		  smallint,		 -- renovar
		  smallint,		 -- no_renovar
		  date,			 -- fecha_selec
		  date,			 -- vigencia_inic
		  date,			 -- vigencia_final
		  dec(16,2),	 -- saldo
		  smallint,		 -- cant_reclamos
		  char(10),		 -- no_factura 
		  decimal(16,2), -- incurrido   
		  decimal(16,2), -- pagos   
		  decimal(5,2),	 -- porc_depreciacion
		  char(5),	   	 -- cod_agente
		  varchar(100),  -- n_cliente
		  char(10),		 -- cod_contratante  
		  smallint,		 -- estatus
		  char(3),	     -- cod_sucursal
		  CHAR(50),		 -- ramo
		  CHAR(50),		 -- telefono
		  CHAR(50),		 -- compania
		  CHAR(50),      -- sucursal
		  SMALLINT,		 -- conoce
		  CHAR(15),		 -- mes
		  CHAR(255),     -- filtros
		  CHAR(50),
		  smallint,
		  char(3);

DEFINE _no_poliza	    	CHAR(10);	 
DEFINE _cod_contratante 	CHAR(10);	 
DEFINE _user_added   		CHAR(8);
DEFINE _cod_no_renov   		CHAR(3);
DEFINE _no_documento		CHAR(20);
DEFINE _renovar   			smallint;
DEFINE _no_renovar			smallint;
DEFINE _fecha_selec			date;
DEFINE _vigencia_inic		date;
DEFINE _vigencia_final		date;
DEFINE _saldo				dec(16,2);
DEFINE _cant_reclamos		smallint;
DEFINE _no_factura			char(10);
DEFINE _incurrido			dec(16,2);
DEFINE _pagos   			dec(16,2);
DEFINE _porc_depreciacion  	dec(5,2);
DEFINE _cod_agente  		char(5);
DEFINE _saldo_porc      	integer;
DEFINE _n_cliente       	varchar(100);
DEFINE _n_corredor      	varchar(50);
DEFINE _fecha_hoy       	date;
DEFINE _estatus         	smallint;
DEFINE _cod_sucursal  		CHAR(3);
DEFINE _no_poliza2      	CHAR(10);
DEFINE _sucursal        	CHAR(3);
DEFINE _cod_ramo        	CHAR(3);
DEFINE _suc_prom        	CHAR(3);
DEFINE v_nombre_ramo   	 	CHAR(50);
DEFINE v_telefono   	 	CHAR(50);
DEFINE v_compania   	 	CHAR(50);
DEFINE v_sucursal   	 	CHAR(50);
DEFINE v_tel1			 	CHAR(10);
DEFINE v_tel2			 	CHAR(10);
DEFINE v_tel3			 	CHAR(10);
DEFINE v_celular	  	 	CHAR(10);
DEFINE v_conoce          	smallint;
DEFINE ls_fecha_letra    	CHAR(15);
DEFINE _cantidad          	smallint;
DEFINE v_filtros            CHAR(255);
DEFINE _tipo                CHAR(01);
DEFINE _desc_exc			CHAR(50);
DEFINE _renglon				smallint;
DEFINE _activo				smallint;
DEFINE _mes					integer;
DEFINE _cod_tipoprod		char(3);

LET v_nombre_ramo = '';
LET v_telefono    = '';
LET v_compania    = '';
LET v_sucursal    = '';

LET v_compania  = sp_sis01("001");

SELECT trim(descripcion)
  INTO v_sucursal
  FROM insagen
 WHERE codigo_agencia  = a_sucursal
   AND codigo_compania = "001";

LET _fecha_hoy = current;

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_pro994.trc";	  	  	  	

-- Procesos v_filtros
LET v_filtros ="";

--Filtro por Ramo
 IF a_codramo <> "*" THEN
    LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
    LET _tipo = sp_sis04(a_codramo);  -- Separa los valores del String
END IF

--trace on;
foreach
  SELECT no_poliza,   
         user_added,   
         cod_no_renov,   
         no_documento,   
         renovar,   
         no_renovar,   
         fecha_selec,   
         vigencia_inic,   
         vigencia_final,   
         saldo,   
         cant_reclamos,   
         no_factura,   
         incurrido,   
         pagos,   
         porc_depreciacion,   
         cod_agente,
         estatus,
         cod_sucursal
	INTO _no_poliza,
		 _user_added,   
		 _cod_no_renov,   
		 _no_documento,   
		 _renovar,   
		 _no_renovar,   
		 _fecha_selec,   
		 _vigencia_inic,   
		 _vigencia_final,   
		 _saldo,   
		 _cant_reclamos,   
		 _no_factura,   
		 _incurrido,   
		 _pagos,   
		 _porc_depreciacion,
		 _cod_agente,
         _estatus,
         _cod_sucursal 
    FROM emirepo  
   WHERE estatus  not in (5,9,1)
	 AND vigencia_final >=  a_desde
	 AND vigencia_final <=  a_hasta

--   AND month(vigencia_final) = a_mes
--   AND user_added =  "AUTOMATI"
--	 AND no_poliza = '1709-00033-01'

	let _no_poliza2 = sp_sis21(_no_documento);
	let _cantidad = 0;
	let _mes = month(_vigencia_final) ;

  SELECT cod_contratante,
         vigencia_inic,
		 vigencia_final,
		 sucursal_origen,
		 cod_ramo,
		 cod_tipoprod
  	INTO _cod_contratante,
	     _vigencia_inic,
		 _vigencia_final,
		 _sucursal,
		 _cod_ramo,
		 _cod_tipoprod
  	FROM emipomae
   WHERE no_poliza = _no_poliza2;

	if _cod_tipoprod = "001" then
		let _cod_tipoprod = 'MAY';
	elif _cod_tipoprod = "002" then
		let _cod_tipoprod = 'MIN';
	else
		let _cod_tipoprod = '';
	end if

	IF a_codramo <> "*" THEN   -- filtro solicitado

		SELECT count(*)
		  INTO _cantidad
		  FROM tmp_codigos
		 WHERE trim(codigo) IN (trim(_cod_ramo));

		 if _tipo <> "E" then
			if _cantidad = 0 then
				CONTINUE FOREACH;
			end if
		 else
			if _cantidad = 1 then
				CONTINUE FOREACH;
			end if
		 end if

	END IF

	select sucursal_promotoria
	  into _suc_prom
	  from insagen
	 where codigo_agencia  = _sucursal
	   and codigo_compania = '001';

  { 	if _cod_ramo <> "008" then  -- fianzas si se imprime en casa matriz siempre.
			if a_sucursal <> _suc_prom then 
				CONTINUE FOREACH;	
			end if
	   	end if	}

	--Selecciona los nombres de Ramos
	SELECT nombre
	  INTO v_nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	let v_conoce = 0;
	--Selecciona los nombres de Clientes
	SELECT nombre,telefono1,telefono2 ,telefono3, celular, conoce_cliente
	  INTO _n_cliente,v_tel1,v_tel2,v_tel3,v_celular,v_conoce
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante ;

	let v_telefono = ''; 
	if v_celular is not null then
		let v_telefono = trim(v_celular)||'/'||trim(v_telefono) ;  
	end if	
	if  v_tel3 is not null then
		let v_telefono = trim(v_tel3)||'/'||trim(v_telefono) ; 
	end if
	if  v_tel2 is not null then
		let v_telefono = trim(v_tel2)||'/'||trim(v_telefono) ; 
	end if
	if  v_tel1 is not null then
		let v_telefono = trim(v_tel1)||'/'||trim(v_telefono) ; 
	end if	  
	if v_telefono is null then
		let v_telefono  = ''; 
	end if	

	SELECT nombre
	INTO _n_corredor
	FROM agtagent
	WHERE cod_agente = _cod_agente;

	IF _mes = 1 THEN
	  LET ls_fecha_letra = 'enero';
	ELIF _mes = 2 THEN
	  LET ls_fecha_letra = 'febrero';
	ELIF _mes = 3 THEN
	  LET ls_fecha_letra = 'marzo';
	ELIF _mes = 4 THEN
	  LET ls_fecha_letra = 'abril';
	ELIF _mes = 5 THEN
	  LET ls_fecha_letra = 'mayo';
	ELIF _mes = 6 THEN
	  LET ls_fecha_letra = 'junio';
	ELIF _mes = 7 THEN
	  LET ls_fecha_letra = 'julio';
	ELIF _mes = 8 THEN
	  LET ls_fecha_letra = 'agosto';
	ELIF _mes = 9 THEN
	  LET ls_fecha_letra = 'septiembre';
	ELIF _mes = 10 THEN
	  LET ls_fecha_letra = 'octubre';
	ELIF _mes = 11 THEN
	  LET ls_fecha_letra = 'noviembre';
	ELIF _mes = 12 THEN
	  LET ls_fecha_letra = 'diciembre';
	END IF

   foreach
	   select renglon,
	          activo
	     into _renglon,
		      _activo
	     from emideren
	    where no_poliza = _no_poliza
	    
	   select descripcion
	     into _desc_exc
	     from emiusuex
	    where renglon = _renglon;   	

	   return _n_corredor,
	   		  _no_poliza,
	   		  _user_added,   
	   		  _cod_no_renov,   
			  _no_documento,   
			  _renovar,   
			  _no_renovar,   
			  _fecha_selec,   
			  _vigencia_inic,   
			  _vigencia_final,   
			  _saldo,   
			  _cant_reclamos,   
			  _no_factura,   
			  _incurrido,   
			  _pagos,   
			  _porc_depreciacion,
			  _cod_agente,
			  _n_cliente,
			  _cod_contratante,
			  _estatus,
			  _cod_sucursal,
			  v_nombre_ramo,
			  v_telefono,
			  v_compania,
			  v_sucursal,
			  v_conoce,
			  ls_fecha_letra,
			  v_filtros,
			  _desc_exc,
			  _activo ,
			  _cod_tipoprod
			  with resume;

	end foreach
end foreach

IF a_codramo <> "*" THEN
	DROP TABLE tmp_codigos ;
END IF

END PROCEDURE  