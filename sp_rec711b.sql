-- Reporte Detalle de transacciones de PAGO
-- Creado    : 07/05/2010 - Autor: Henry Giron
-- ALTAS     : PAGADO 0 GENERAR_CHEQUE = 1
-- BAJAS	 : PAGADO 1 GENERAR_CHEQUE = 1
-- ANULADO	 : PAGADO 0 ANULAR_NT <> ""
--drop procedure sp_rec711b;
create procedure sp_rec711b(a_compania char(3), a_fecha1 date, a_fecha2 date, a_ramo char(255) )
returning char(100), 	-- proveedor
		  char(18), 	-- reclamo
		  dec(16,2), 	-- monto_tran
		  date, 		-- fecha
		  char(50), 	-- nom_tipopago
		  char(10),		-- transaccion
		  char(100),	-- desc_ramo
		  char(20),		-- grupo              
		  char(255);    -- filtros      

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _nom_recla		char(100);
define _nom_aseg		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _cod_asegurado	char(10);
define _cod_reclamante	char(10);
define _no_reclamo		char(10);
define _monto_tran		dec(16,2);
define _fecha			date;
define _transaccion		char(10);
define _reclamo			char(18);
define _pagado		    smallint;
define _generar_cheque  smallint;
define _anular_nt		char(10);
define _cod_proveedor   char(10);
define _n_proveedor		char(100);
define _grupo    		char(20);
define _desc_ramo		char(100);
DEFINE _no_poliza       CHAR(10);
define _periodo 		char(7);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _doc_poliza      CHAR(20);
DEFINE _cod_sucursal    CHAR(3);
DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(01);
DEFINE _cantidad        smallint;

SET ISOLATION TO DIRTY READ;
-- Procesos v_filtros
LET v_filtros ="";

--Filtro por Ramo
IF a_ramo <> "*" THEN
 LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_ramo);
 LET _tipo = sp_sis04(a_ramo);  -- Separa los valores del String
END IF

foreach
select cod_tipopago,
	   transaccion,
	   fecha,
	   monto,
	   no_reclamo,
	   no_requis,
	   cod_proveedor,
	   anular_nt,
	   pagado,
	   generar_cheque
  into _cod_tipopago,
	   _transaccion,
	   _fecha,
	   _monto_tran,
	   _no_reclamo,
	   _no_requis,
	   _cod_proveedor,
	   _anular_nt,
	   _pagado,
	   _generar_cheque
  from rectrmae
 where cod_compania = a_compania
   and actualizado  = 1
   and cod_tipotran = "004"
   and fecha        >= a_fecha1
   and fecha        <= a_fecha2

	-- Lectura de la Tablas de Reclamos

 select cod_asegurado,
		cod_reclamante,
		numrecla,
		no_poliza,
        periodo
   into _cod_asegurado,
		_cod_reclamante,
		_reclamo,
		_no_poliza,
        _periodo
   from recrcmae
  where no_reclamo = _no_reclamo;

     -- Informacion de Polizas

 select cod_ramo,
	    cod_grupo,
	    cod_subramo,
	    cod_contratante,
	    no_documento,
	    cod_sucursal
   into _cod_ramo,
        _cod_grupo,
        _cod_subramo,
	    _cod_cliente,
	    _doc_poliza,
	    _cod_sucursal
   from emipomae
  where no_poliza = _no_poliza;

	IF a_ramo <> "*" THEN   

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

 select nombre
   into _desc_ramo
   from prdramo
  where cod_ramo = _cod_ramo;

 select nombre
   into _nom_tipopago
   from rectipag
  where cod_tipopago = _cod_tipopago;

 select nombre
   into _nom_recla
   from cliclien
  where cod_cliente = _cod_reclamante;

 select nombre
   into _n_proveedor
   from cliclien
  where cod_cliente = _cod_proveedor;

 select nombre
   into _nom_aseg
   from cliclien
  where cod_cliente = _cod_asegurado;

	-- Grupo del Reporte 
	let _grupo = "1 - NO PAGADAS";
	if _pagado = 0 and _generar_cheque = 1 then 
	   let _grupo = "1 - NO PAGADAS";
	elif _pagado = 1 and _generar_cheque = 1 then 
	   let _grupo = "2 - PAGADAS";
	elif _pagado = 0 and _anular_nt <> "" then 
	   let _grupo = "3 - ANULADAS";
	end if

 return _n_proveedor,
  	    _reclamo,
   	    _monto_tran,
	    _fecha,
	    _nom_tipopago,
	    _transaccion,
		_desc_ramo,
		_grupo,
		v_filtros
	    with resume;

end foreach
   
IF a_ramo <> "*" THEN
	DROP TABLE tmp_codigos ;
END IF

end procedure  	