-- Reporte Detalle de requisiciones de PAGO - CHEQUE
-- Creado    : 11/05/2010 - Autor:  Henry Giron
-- ALTAS     : PAGADO 0 ANULADO = 0 AUTORIZADO = 1
-- BAJAS	 : PAGADO 1 ANULADO = 0 AUTORIZADO = 1
-- ANULADO	 : PAGADO 0 ANULADO = 1

drop procedure sp_rec712;
create procedure sp_rec712(a_compania char(3), a_fecha1 date, a_fecha2 date, a_ramo char(255) )
returning char(100), 	-- proveedor
		  char(18), 	-- reclamo
		  dec(16,2), 	-- monto_tran
		  date, 		-- fecha
		  char(50), 	-- nom_tipopago
		  char(10),		-- transaccion
		  char(100),	-- desc_ramo
		  char(20),		-- grupo              
		  char(255),    -- filtros      
		  char(100),	-- a_nombre_de
		  char(20),		-- periodo_pago
		  char(10),		-- no_requis
		  dec(16,2);	-- d_monto_tran

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
define _anular_nt		smallint; 
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
define n_periodo_pago   char(20);
define _autorizado      smallint;
define _cliente_ck		char(10);
define d_monto_tran     dec(16,2);

CREATE TEMP TABLE tmp_chqchmae(
	no_requis	   		char(10),
	cod_cliente    		char(10),
	monto		   		dec(16,2),
	a_nombre_de    		char(100),
	periodo_pago   		char(7),
	firma1		   		char(8),
	firma2		   		char(8),
	anulado		   		smallint,
	pagado         		smallint,
	autorizado     		smallint,
	fecha_impresion		date
	) WITH NO LOG; 	

SET ISOLATION TO DIRTY READ;

-- Procesos v_filtros
LET v_filtros = "";

--Filtro por Ramo
IF a_ramo <> "*" THEN
 	LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_ramo);
 	LET _tipo = sp_sis04(a_ramo);   -- Separa los valores del String
END IF

let d_monto_tran = 0;

--Ingreso de pagadas por fecha de impresion
foreach
 select	no_requis,
		cod_cliente,
		monto,
		a_nombre_de,
		periodo_pago,
		firma1,
		firma2,
		anulado,
		pagado,
		autorizado,
		fecha_impresion
   into	_no_requis,
		_cliente_ck,
		_monto_tran,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_anular_nt,
	    _pagado,
	    _autorizado,
		_fecha
   from	chqchmae
  where en_firma        in (0,2)
    and origen_cheque   = "3"
    and fecha_impresion >= a_fecha1
    and fecha_impresion <= a_fecha2

		INSERT INTO tmp_chqchmae (
			no_requis,
			cod_cliente,
			monto,
			a_nombre_de,
			periodo_pago,
			firma1,
			firma2,
			anulado,
			pagado,
			autorizado,
			fecha_impresion	  )
			VALUES ( 
			_no_requis,
			_cliente_ck,
			_monto_tran,
			_a_nombre_de,
			_periodo_pago,
			_firma1,
			_firma2,
			_anular_nt,
			_pagado,
			_autorizado,
			_fecha	);

end foreach

--Ingresos de anuladas por fecha de anulado
foreach
 select	no_requis,
		cod_cliente,
		monto,
		a_nombre_de,
		periodo_pago,
		firma1,
		firma2,
		anulado,
		pagado,
		autorizado,
		fecha_anulado
   into	_no_requis,
		_cliente_ck,
		_monto_tran,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_anular_nt,
	    _pagado,
	    _autorizado,
		_fecha
   from	chqchmae
  where en_firma      in (0,2)
    and origen_cheque = "3"
    and fecha_anulado >= a_fecha1
    and fecha_anulado <= a_fecha2

		INSERT INTO tmp_chqchmae (
			no_requis,
			cod_cliente,
			monto,
			a_nombre_de,
			periodo_pago,
			firma1,
			firma2,
			anulado,
			pagado,
			autorizado,
			fecha_impresion	  )
			VALUES ( 
			_no_requis,
			_cliente_ck,
			_monto_tran,
			_a_nombre_de,
			_periodo_pago,
			_firma1,
			_firma2,
			_anular_nt,
			_pagado,
			_autorizado,
			_fecha
			);

end foreach

foreach
 select	no_requis,
		cod_cliente,
		monto,
		a_nombre_de,
		periodo_pago,
		firma1,
		firma2,
		anulado,
		pagado,
		autorizado,
		fecha_impresion		
   into	_no_requis,
		_cliente_ck,
		_monto_tran,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_anular_nt,
	    _pagado,
	    _autorizado,
		_fecha
   from	tmp_chqchmae
   order by 1

       foreach
		select numrecla,
		       transaccion,
		       monto 
		  into _reclamo,
		       _transaccion,
			   d_monto_tran
		  from chqchrec 
		 where no_requis = _no_requis

		select cod_tipopago,
			   no_reclamo,
			   cod_proveedor
		  into _cod_tipopago,
			   _no_reclamo,
			   _cod_proveedor
		  from rectrmae
		 where cod_compania = a_compania
		   and actualizado  = 1
		   and cod_tipotran = "004"
		   and no_requis    = _no_requis
		   and numrecla     = _reclamo
		   and transaccion  = _transaccion;

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
		  where cod_cliente = _cliente_ck ; --_cod_proveedor;

		 select nombre
		   into _nom_aseg
		   from cliclien
		  where cod_cliente = _cod_asegurado;

			-- Grupo del Reporte 
			let _grupo ="1 - NO PAGADAS";
			if _pagado = 0 then 
			   let _grupo = "1 - NO PAGADAS";
			elif _pagado = 1 and _autorizado = 1 and _anular_nt = 0 then 
			   let _grupo = "2 - PAGADAS";
			elif _pagado = 1 and _anular_nt = 1 then 
			   let _grupo = "3 - ANULADAS";
			   let _monto_tran = -1 * _monto_tran;
			   let d_monto_tran = -1 * d_monto_tran;
			end if

			-- Tipo de Pago
			let n_periodo_pago ="";
			if _periodo_pago = 0  then 
			   let n_periodo_pago = "DIARIO";
			elif _periodo_pago = 1 then 
			   let n_periodo_pago = "SEMANAL";
			elif _periodo_pago = 0 then 
			   let n_periodo_pago = "MENSUAL";
			end if

		 return _n_proveedor,
		  	    _reclamo,
		   	    _monto_tran,
			    _fecha,
			    _nom_tipopago,
			    _transaccion,
				_desc_ramo,
				_grupo,
				v_filtros,
				_a_nombre_de,
				n_periodo_pago,
				_no_requis,
				d_monto_tran
			    with resume;
	 end foreach

end foreach
   
IF a_ramo <> "*" THEN
	DROP TABLE tmp_codigos ;
END IF
DROP TABLE tmp_chqchmae;

end procedure	