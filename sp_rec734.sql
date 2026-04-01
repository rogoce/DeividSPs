-- Reporte Detalle de transacciones de PAGO
-- Creado    : 16/09/2015 - Autor: Amado Perez

drop procedure sp_rec734;
create procedure sp_rec734(a_compania char(3), a_fecha1 date, a_fecha2 date, a_ramo char(255) default '*', a_concepto char(255) default '*')
returning char(255);     -- orden Compra

define _no_requis		char(10);
define _cod_cliente		char(10);
define _cod_cliente_rec		char(10);
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
DEFINE _no_tramite      char(10);
DEFINE _no_orden_compra char(10);

define _periodo1		char(7);
define _periodo2		char(7);

define _cod_concepto    char(3);
define _no_tranrec      char(10);
define _cod_cobertura   char(5);

CREATE TEMP TABLE tmp_pagos(
		no_reclamo           CHAR(10)  NOT NULL,
		cod_concepto         CHAR(3)   NOT NULL,
		cod_cobertura        CHAR(5)   NOT NULL,
		cod_cliente          CHAR(10)  NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		no_poliza            CHAR(20)  NOT NULL,
		asegurado            CHAR(100) NOT NULL,
		a_nombre_de          CHAR(100) NOT NULL,
		monto                DEC(16,2) DEFAULT 0.00,
		cod_ramo             CHAR(3)   NOT NULL,
		periodo              CHAR(7)   NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (no_reclamo, cod_concepto, cod_cobertura, cod_cliente)
		) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

LET v_filtros ="";

let _periodo1 = sp_sis39(a_fecha1);
let _periodo2 = sp_sis39(a_fecha2);

foreach
	select no_tranrec,
		   no_reclamo,
		   cod_cliente,
		   periodo
	  into _no_tranrec,
		   _no_reclamo,
		   _cod_cliente_rec,
		   _periodo
	  from rectrmae
	 where cod_compania = a_compania
	   and actualizado  = 1
	   and cod_tipotran = "004"
	   and pagado       = 1
	   and periodo      >= _periodo1
	   and periodo      <= _periodo2
	
	let _n_proveedor = null;
	
	select nombre
	  into _n_proveedor
	  from cliclien
	 where cod_cliente = _cod_cliente_rec;
	 
	if _n_proveedor is null then
		let _n_proveedor = "";
	end if
	   
		-- Lectura de la Tablas de Reclamos

	select cod_asegurado,
		   numrecla,
		   no_poliza,
		   no_documento
	  into _cod_asegurado,
		   _reclamo,
		   _no_poliza,
		   _doc_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	select nombre
	  into _nom_aseg
	  from cliclien
	 where cod_cliente = _cod_asegurado;	 
	 
	select cod_ramo
      into _cod_ramo
      from emipomae
     where no_poliza = _no_poliza;	  
  
	foreach
		select cod_concepto,
		       monto
		  into _cod_concepto,
		       _monto
		  from rectrcon
		 where no_tranrec = _no_tranrec
		 
		foreach
			select cod_cobertura,
			       monto
			  into _cod_cobertura,
			       _monto
			  from rectrcob
		     where no_tranrec = _no_tranrec
		 
			begin
				on exception in(-239)
					update tmp_pagos
					   set monto = monto + _monto
					 where no_reclamo = _no_reclamo
					   and cod_concepto = _cod_concepto
					   and cod_cobertura = _cod_cobertura
					   and cod_cliente = _cod_cliente_rec;
				
				end exception
				insert into tmp_pagos 			
				values (
					_no_reclamo,
					_cod_concepto,
					_cod_cobertura,
					_cod_cliente_rec,
					_reclamo,
					_doc_poliza,
					_nom_aseg,
					_n_proveedor,
					_monto,
					_cod_ramo,
					_periodo,
					1
					);
			end
		end foreach
	end foreach

end foreach
   
IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_pagos
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_pagos
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_concepto <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Concepto: " ||  TRIM(a_concepto);

	LET _tipo = sp_sis04(a_concepto);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_pagos
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_concepto NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_pagos
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_concepto IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

return v_filtros;
end procedure  	