-- Pool impresion de informe de renovacion automatica diaria
-- Creado : 18/01/2010 - Autor: Henry Giron.
-- SIS v.2.0 - d_prod_sp_pro987_dw1 - DEIVID, S.A.
DROP PROCEDURE sp_pro987;

CREATE PROCEDURE "informix".sp_pro987(a_sucursal char(3), a_estatus smallint, a_desde date, a_hasta date, a_codramo char(255))
returning varchar(50),	 --_n_corredor,
		  char(10),		 --_no_poliza,
		  char(8),		 --_user_added,   
		  char(3),       --_cod_no_renov,   
		  char(20),		 --_no_documento,   
		  smallint,		 --_renovar,   
		  smallint,		 --_no_renovar,   
		  date,			 --_fecha_selec,   
		  date,			 --_vigencia_inic,   
		  date,			 --_vigencia_final,   
		  dec(16,2),	 --_saldo,   
		  smallint,		 --_cant_reclamos,   
		  char(10),		 --_no_factura,   
		  decimal(16,2), --_incurrido,   
		  decimal(16,2), --_pagos,   
		  decimal(5,2),	 --_porc_depreciacion,
		  char(5),	   	 --_cod_agente,
		  varchar(100),  --_n_cliente,
		  char(10),		 --_cod_contratante  
		  smallint,		 --_estatus
		  char(3),	     --_cod_sucursal
		  CHAR(50),		 -- ramo
		  CHAR(50),		 -- telefono
		  CHAR(50),		 -- compania
		  CHAR(50),		 -- sucursal
		  CHAR(255);     -- filtros


define _no_poliza	    char(10);	 
define _cod_contratante char(10);	 
define _user_added   	char(8);
define _cod_no_renov   	char(3);
define _no_documento	char(20);
define _renovar   		smallint;
define _no_renovar		smallint;
define _fecha_selec		date;
define _vigencia_inic	date;
define _vigencia_final	date;
define _saldo			dec(16,2);
define _cant_reclamos	smallint;
define _no_factura		char(10);
define _incurrido		dec(16,2);
define _pagos   		dec(16,2);
define _porc_depreciacion  dec(5,2);
define _cod_agente  	char(5);
define _saldo_porc      integer;
define _n_cliente       varchar(100);
define _n_corredor      varchar(50);
define _fecha_hoy       date;
define _estatus         smallint;
define _cod_sucursal  	char(3);
define _no_poliza2      char(10);
define _sucursal        char(3);
define _cod_ramo        char(3);
define _suc_prom        char(3);

DEFINE v_nombre_ramo   	 CHAR(50);
DEFINE v_telefono   	 CHAR(50);
DEFINE v_compania   	 CHAR(50);
DEFINE v_sucursal   	 CHAR(50);

DEFINE v_tel1			 CHAR(10);
DEFINE v_tel2			 CHAR(10);
DEFINE v_tel3			 CHAR(10);
DEFINE v_celular	  	 CHAR(10);

DEFINE v_conoce_cliente  smallint;
DEFINE _cantidad          	smallint;
DEFINE v_filtros            CHAR(255);
DEFINE _tipo                CHAR(01);


let v_nombre_ramo = '';
let v_telefono = '';
let v_compania = '';
let v_sucursal = '';
LET v_compania  = sp_sis01("001");

SELECT trim(descripcion)
  INTO v_sucursal
  FROM insagen
 WHERE codigo_agencia  = a_sucursal
   AND codigo_compania = "001";

let _fecha_hoy = current;

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_pro987.trc";	  	  	  	
--trace on;

-- Procesos v_filtros
LET v_filtros ="";

--Filtro por Ramo
IF a_codramo <> "*" THEN
 LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
 LET _tipo = sp_sis04(a_codramo);  -- Separa los valores del String
END IF

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
   WHERE estatus   in ( a_estatus,9)
   and fecha_selec >=  a_desde
   and fecha_selec <=  a_hasta

	let _no_poliza2 = sp_sis21(_no_documento);

  SELECT cod_contratante,
         vigencia_inic,
		 vigencia_final,
		 sucursal_origen,
		 cod_ramo
  	INTO _cod_contratante,
	     _vigencia_inic,
		 _vigencia_final,
		 _sucursal,
		 _cod_ramo
  	FROM emipomae
   WHERE no_poliza = _no_poliza2;

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

   	if _cod_ramo <> "008" then  -- fianzas si se imprime en casa matriz siempre.
		if a_sucursal <> _suc_prom then 
			CONTINUE FOREACH;
		end if
   	end if

	--Selecciona los nombres de Ramos
	SELECT nombre
	   INTO v_nombre_ramo
	FROM prdramo
	WHERE cod_ramo = _cod_ramo;

	--Selecciona los nombres de Clientes
	SELECT nombre,telefono1,telefono2 ,telefono3, celular
	   INTO _n_cliente,v_tel1,v_tel2,v_tel3,v_celular
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
		  v_filtros 
		  with resume;
end foreach

IF a_codramo <> "*" THEN
	DROP TABLE tmp_codigos ;
END IF

END PROCEDURE  