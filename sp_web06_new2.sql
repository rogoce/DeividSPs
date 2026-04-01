-- Obtener el estado de los cheques de los hospitales
-- Creado    : 21/12/2010 - Autor: Federico Coronado
-- Modificado: 23/08/2022 - Autor: Federico Coronado
-- SIS - Pagina Web.

drop procedure sp_web06_new2;

create procedure "informix".sp_web06_new2(a_id_proveedor char(10),a_cod_entrada varchar(10))
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

--set debug file to "sp_web06_new.trc"; 
--trace on;

let _fecha   = today;
let _fecha   = _fecha - 1 units year;
let _periodo = sp_sis39(_fecha);

let _periodo = _periodo[1,4]||'-01';

set isolation to dirty read;

-- busqueda por id del proveedor

	if a_cod_entrada = ' ' then
		
		foreach
			 SELECT 
					no_reclamo,
					numrecla,
					no_factura,
					fecha_factura,
					transaccion,
					pagado,
					no_requis,
					cod_tipotran,
					rectrmae.monto,
					no_tranrec,
					cod_asignacion,
					cod_tipopago
			   into _no_reclamo,
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
					_cod_tipopago
			   FROM rectrmae
			  where cod_compania = "001"
					and actualizado  = 1
					and periodo      >= _periodo
					and cod_tipotran in ('013', '004')
					and (cod_tipopago = '001'  or  cod_tipopago is null)
					and cod_cliente  = a_id_proveedor
					and anular_nt    is null
					order by fecha_factura DESC

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
							--if _wf_entregado = 1 then
								--let _estatus = "Pagado y Retirado";
							--else
								--let _estatus = "Pagado por Retirar";
							--end if
						else
						  -- let _estatus = "En Firma";
						  let _estatus = "En Proceso";
						end if
					else
						--if _en_firma = 0 then
							let _estatus = "En Proceso";
						--else
							--let _estatus = "En Firma";
						--end if
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
		end foreach
	else
		foreach
			SELECT b.cod_asignacion,
				   b.cod_entrada,
				   b.cod_asegurado,
				   b.cod_reclamante,
				   date(b.date_added), 
				   b.no_documento, 
				   b.no_unidad,
				   b.monto,
				   b.cod_tipopago, 
				   a.nombre
			  into _cod_asignacion,
				   _cod_entrada,
				   _cod_asegurado,
				   _cod_reclamante,
				   _fecha_reclamo,
				   _no_documento,
				   _no_unidad,
				   _monto,
				   _cod_tipopago,
				   _nombre_paciente
			  FROM atcdocma a inner join atcdocde b on a.cod_entrada = b.cod_entrada
			 where  b.completado = 0
			   --and procesado = 0
			   and (cod_tipopago = '001'  or  cod_tipopago is null)
			   and b.cod_entrada = a_cod_entrada

			SELECT nombre, cedula
			  into _nombre_paciente,_cedula
			  FROM cliclien
			 where cod_cliente = _cod_reclamante;

			   return _no_documento, 	--1
								 '',    --2
								 '',    --3
					  _fecha_reclamo,   --4
					  _nombre_paciente, --5
								 '',    --6
								 '',    --7
								 '',    --8
								 '',    --9
					   "En Tramite",    --10
								 '',    --11
								 '',    --12
								 '',    --13
								 '',    --14
								 '',    --15
								 '',    --16
					   _cod_entrada,    --17
								 '',    --18
					 _fecha_reclamo,	--19
						 _no_unidad,	--20
							_cedula,	--21
							 _monto,	--22
								 '',	--23
								 '',	--24
								 '',	--25
								 '',	--26
								 '',    --27
								 ''		--28
								with resume;
		end foreach
	end if
end procedure