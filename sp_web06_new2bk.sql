-- Listado de pólizas Acreedores
-- Creado    : 07/08/2019 - Autor: Federico Coronado

DROP PROCEDURE sp_web06_new2bk;

CREATE PROCEDURE sp_web06_new2bk(a_sql_describe lvarchar) 
returning 		char(20)		as No_Documento,
				char(20)		as Numrecla,
				varchar(10)		as No_Factura,
				date			as Fecha_Factura,
				char(40)		as Nombre_paciente,
				char(10)		as Transaccion,
				char(10)		as No_Cheque,
				date			as Wf_Fecha,
				char(30)		as Wf_Nombre,
				varchar(20)		as Estado,
				integer			as Wf_Entregado,
				integer			as Wf_Pagado,
				integer			as Pagado,
				char(10)		as Wf_Cedula,
				decimal(10,2)	as Monto,
				decimal(10,2)	as Gasto_no_Cubierto,
				char(10)		as Cod_entrada,
				char(3)			as Tipo_transaccion,
				date			as Fecha_Reclamo,
				varchar(5)		as No_unidad,
				varchar(30)		as Cedula,
				dec(16,2)       as Gasto_facturado,			
				dec(16,2)		as Gasto_elegible,			
				dec(16,2)		as A_Deducible,			
				dec(16,2)		as Co_pago,			
				dec(16,2)		as Coaseguro,
				varchar(50)		as Descripago,
				varchar(50)		as no_requis;
			
			
define _no_reclamo 				char(10);
define _no_factura 				varchar(10);
define _fecha_factura 			char(10);
define _no_documento 			char(20);
define _cod_asegurado 			char(10);
define _nombre_paciente 		char(40);
define _transaccion 			char(10);
define _pagado 					char(10);
define _no_requis 				char(20);
define _numrecla 				char(20);
define _fecha_reclamo 			date;
define _periodo					char(7);
define _tipotran 				char(3);
define _no_cheque 				char(10);
define _wf_fecha 				char(10);
define _wf_nombre 				char(30);
define _wf_cedula 				char(10);
define _cod_reclamante 			char(10);
define _cod_asignacion 			char(10);
define _cod_icd 				char(10);
define _cod_entrada 			char(10);
define _cod_tipopago 			char(3);
define _wf_pagado 				integer;
define _wf_entregado 			integer;
define _en_firma 				smallint;
define _no_unidad 				varchar(5);
define _cedula              	varchar(30);
define _estatus					varchar(20);
define _no_tranrec 				varchar(10);
define _monto 					decimal(10,2);
define _gastos_no_cub 			decimal(10,2);
define _gasto_fact				dec(16,2);
define _gasto_eleg				dec(16,2);
define _a_deducible				dec(16,2);
define _co_pago					dec(16,2);
define _coaseguro				dec(16,2);
define _descripago				varchar(50);
define _fecha					date;		

--SET DEBUG FILE TO "sp_webcon01.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

prepare equisql from a_sql_describe;	
declare equicur cursor for equisql;
open equicur;
	while (1 = 1)
		fetch equicur into	 _no_reclamo,
							 _numrecla,
							 _no_factura,
							 _fecha_factura,
							 _transaccion,
							 _pagado,
							 _no_requis,
							 _tipotran,
							 _monto,
							 _no_tranrec,
							 _cod_asignacion,
							 _cod_tipopago;
		IF (SQLCODE = 100) THEN
			EXIT;
		END IF
		
		let _no_cheque 		= '';
		let _wf_pagado 		= '';
		let _wf_entregado	= '';
		let _wf_fecha 		= '';
		let _wf_nombre 		= '';
		let _wf_cedula 		= '';
		let _descripago     = '';

		if _tipotran = '013'	then

			let _estatus = "Declinado";

		else
			SELECT no_cheque,
				   pagado,
				   wf_entregado,
				   wf_fecha,
				   wf_nombre,
				   wf_cedula,
				   en_firma
			  into _no_cheque,
				   _wf_pagado,
				   _wf_entregado,
				   _wf_fecha,
				   _wf_nombre,
				   _wf_cedula,
				   _en_firma
			  FROM chqchmae
			  where no_requis = _no_requis;

			if _pagado = 1 then	--inicio pagado rectrmae
				if _wf_pagado = 1 then
					 let _estatus = "Pagado";
					if _cod_tipopago is not null or trim(_cod_tipopago) <> '' then
						 select nombre
						 into _descripago 
						 from rectipag where cod_tipopago = _cod_tipopago;
					 end if
				else
				  let _estatus = "En Proceso";
				end if
			else
					let _estatus = "En Proceso";
			end if -- fin de pagado tabla rectrmae
				end if --fin del if de 013 declinado

			SELECT no_documento,
				   cod_asegurado,
				   cod_reclamante,
				   cod_icd,
				   fecha_documento,
				   no_unidad
			  into _no_documento,
				   _cod_asegurado,
				   _cod_reclamante,
				   _cod_icd,
				   _fecha_reclamo,
				   _no_unidad
			FROM recrcmae
			where no_reclamo = _no_reclamo;

			 select sum(monto_no_cubierto),
					sum(facturado),
					sum(elegible),
					sum(a_deducible),
					sum(co_pago),
					sum(coaseguro)
			   into	_gastos_no_cub,
					_gasto_fact,
					_gasto_eleg,
					_a_deducible,
					_co_pago,
					_coaseguro
			   from rectrcob
			  where no_tranrec = _no_tranrec;

			SELECT nombre, 
			       cedula
			  into _nombre_paciente,
			       _cedula
			  FROM cliclien
			 where cod_cliente = _cod_reclamante;
			 
			select cod_entrada
			  into  _cod_entrada
			  from atcdocde
			 where cod_asignacion = _cod_asignacion;

			select fecha
			  into  _fecha_reclamo
			  from atcdocma
			 where cod_entrada = _cod_entrada;

		   return _no_documento,	    --01
				  _numrecla,			--02
				  _no_factura,			--03
				  _fecha_factura,		--04
				  _nombre_paciente,		--05
				  _transaccion,			--06
				  _no_cheque,			--07
				  _wf_fecha,			--08
				  _wf_nombre,			--09
				  _estatus,				--10
				  _wf_entregado,		--11
				  _wf_pagado,			--12
				  _pagado,	 			--13
				  _wf_cedula,			--14
				  _monto,				--15
				  _gastos_no_cub,       --16
				  _cod_entrada,         --17
				  _tipotran,            --18
				  _fecha_reclamo,		--19
				  _no_unidad,		    --20
				  _cedula,				--21
				  _gasto_fact,			--22
				  _gasto_eleg,			--23
				  _a_deducible,		    --24
				  _co_pago,			    --25
				  _coaseguro,			--26
				  _descripago,          --27
				  _no_requis			--28
				  with resume;
				
				  let _no_requis = '';

			end while
	close equicur;	
	free equicur;
	free equisql;				  
END PROCEDURE;