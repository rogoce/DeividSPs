-- Reporte Detalle de transacciones de PAGO
-- Creado    : 07/05/2010 - Autor: Henry Giron
-- ALTAS     : PAGADO 0 GENERAR_CHEQUE = 1
-- BAJAS	 : PAGADO 1 GENERAR_CHEQUE = 1
-- ANULADO	 : PAGADO 0 ANULAR_NT <> ""
--drop procedure sp_rec711a;
create procedure sp_rec711a(a_compania char(3), a_fecha1 date, a_fecha2 date)
returning date,
          char(10),
		  char(100),
		  dec(16,2),
		  char(18), 
		  char(1),
		  char(20), 
		  char(50);	

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
define _n_nombre_ajust  char(50);
define _estatus_reclamo char(1);
define _ajust_interno   char(3);

SET ISOLATION TO DIRTY READ;
-- Procesos v_filtros
LET v_filtros ="";

foreach
	select numrecla,
	       monto
	  into _reclamo,
	       _monto_tran
	  from rectrmae
	 where cod_compania = a_compania
	   and actualizado  = 1
	   and cod_tipotran = "004"
	   and pagado       = 1
	   and generar_cheque = 1
	   and fecha        >= a_fecha1
	   and fecha        <= a_fecha2
	group by  1,2
	having count(*) > 1
	order by 1,2

	foreach

	select cod_tipopago,
		   transaccion,
		   fecha,
		   monto,
		   no_reclamo,
		   no_requis,
		   cod_cliente,
		   anular_nt,
		   pagado,
		   generar_cheque,
		   numrecla
	  into _cod_tipopago,
		   _transaccion,
		   _fecha,
		   _monto_tran,
		   _no_reclamo,
		   _no_requis,
		   _cod_proveedor,
		   _anular_nt,
		   _pagado,
		   _generar_cheque,
		   _reclamo
	  from rectrmae
	 where numrecla = _reclamo
	   and actualizado  = 1
	   and monto = _monto_tran

		-- Lectura de la Tablas de Reclamos

	 select cod_asegurado,
			cod_reclamante,
			numrecla,
			no_poliza,
	        periodo,
			estatus_reclamo,
			ajust_interno
	   into _cod_asegurado,
			_cod_reclamante,
			_reclamo,
			_no_poliza,
	        _periodo,
			_estatus_reclamo,
			_ajust_interno
	   from recrcmae
	  where no_reclamo = _no_reclamo;

	     -- Informacion de Polizas

	 select no_documento
	   into _doc_poliza
	   from emipomae
	  where no_poliza = _no_poliza;

	{ select nombre
	   into _nom_recla
	   from cliclien
	  where cod_cliente = _cod_reclamante;}

	 select nombre
	   into _n_proveedor
	   from cliclien
	  where cod_cliente = _cod_proveedor;

	{ select nombre
	   into _nom_aseg
	   from cliclien
	  where cod_cliente = _cod_asegurado;}

	 select nombre
	   into _n_nombre_ajust
	   from recajust
	  where cod_ajustador = _ajust_interno;


	 return _fecha,
		    _transaccion,
			_n_proveedor,
			_monto_tran,
			_reclamo,
			_estatus_reclamo,
			_doc_poliza,
			_n_nombre_ajust
		    with resume;


	end foreach
end foreach
end procedure  	