-- Obtener el estado de los reclamos el modulo web de consulta corredores

-- Creado: 29/11/2011 - Autor: Federico Coronado

-- SIS - Pagina Web consulta de el estado de los reclamos modulo de los corredores consultas web.

drop procedure sp_web20;

create procedure "informix".sp_web20(a_no_documento char(20), a_cod_reclamante varchar(10), a_periodo varchar(7) default "*")
returning char(20),
varchar(20),
varchar(20),
varchar(20),
varchar(20),
varchar(20),
varchar(20),
varchar(20),
varchar(20),
varchar(20),
decimal(10,2),
varchar(20),
varchar(20),
varchar(20),
varchar(20),
varchar(10),
varchar(20),
varchar(20),
char(10),
char(3);

define _no_reclamo varchar(20);
define _cod_asignacion varchar(20);
define _fecha_factura date;
define _fecha	date;
define _tipotran varchar(10);
define _no_requis varchar(20);
define _numrecla varchar(20);

define _periodo	varchar(7);
define _no_cheque varchar(10);
define _pagado char(10);
define _cod_entrada char(10);

define _estatus	varchar(20);
define _no_tranrec varchar(10);
define _transaccion varchar(10);

define _wf_pagado integer;
define _wf_entregado integer;
define _en_firma smallint;
define _wf_fecha char(10);
define _wf_nombre char(30);
define _wf_cedula char(10);
define _cod_icd char(10);

define _monto decimal(10,2);
define _gastos_no_cub decimal(10,2);
define  _facturado decimal(10,2);
define _elegible decimal(10,2);
define _deducible decimal(10,2);
define _co_pago decimal(10,2);
define _coaseguro decimal(10,2);
define _pago_prov decimal(10,2);
define _gasto_eleg decimal(10,2);
define _gasto_fact decimal(10,2);
define _cod_tipopago char(3);

--let _fecha   = today;
--let _fecha   = _fecha - 10 units month;
--let _periodo = sp_sis39(_fecha);
let _no_cheque = 0;

set isolation to dirty read;
 if a_periodo = '' then
              let a_periodo='';
			  -- antes *
   end if
   
-- busqueda por no_poliza si en valor de cod_reclamante es nulo 
if trim(a_cod_reclamante) <> '' then
foreach
	 SELECT fecha_factura,
					pagado,
					recrcmae.numrecla,
					facturado,
					elegible,
					a_deducible,
					co_pago,
					coaseguro,
					rectrmae.monto,
					cod_tipotran,
					no_tranrec,
					no_requis,
					recrcmae.no_reclamo,
					rectrmae.cod_asignacion,
					rectrmae.transaccion,
					recrcmae.cod_icd,
                    cod_tipopago					
			 into _fecha_factura,
                  _pagado,
                  _numrecla,
                  _facturado,
                  _elegible,
                  _deducible,
                  _co_pago,
                  _coaseguro,
                  _monto,
                  _tipotran,
                  _no_tranrec,
                  _no_requis,
                  _no_reclamo,
                  _cod_asignacion,
                  _transaccion,
                  _cod_icd,
				  _cod_tipopago
             FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
  --				  /*inner join atcdocde on atcdocde.cod_asignacion = recrcmae.cod_asignacion*/
             where recrcmae.cod_compania = "001"
             and recrcmae.actualizado  = 1
             and rectrmae.periodo like "%"||a_periodo||"%"
	---		 /*a_periodo*/
             and cod_tipotran in ('013', '004')
--			 /*and rectrmae.cod_tipopago = '003' /*pago a Asegurados*/
             and anular_nt    is null
			 and rectrmae.transaccion is not null
             and recrcmae.no_documento = a_no_documento
	         and recrcmae.cod_reclamante = a_cod_reclamante
             order by fecha_factura DESC


  let _no_cheque = 0;
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
							 
						else
						
						  let _estatus = "En Proceso";
						  
						end if
						
					else
					
							if _monto = '0.00' then
							
								let _estatus = "A Deducible";
								
							else
							
								let _estatus = "En Proceso";
								
							end if
							
					end if -- fin de pagado tabla rectrmae

	end if --fin del if de 013 declinado


		 select	facturado,
		        elegible,
			   	a_deducible,
				co_pago,
				coaseguro,
				monto,
				monto_no_cubierto
		  into	_facturado,
		        _gasto_eleg,
				_deducible,
				_co_pago,
				_coaseguro,
				_pago_prov,
				_gastos_no_cub
		  from rectrcob
		  where no_tranrec = _no_tranrec; 

		 select cod_entrada
		 into  _cod_entrada
		 from atcdocde
		 where cod_asignacion = _cod_asignacion;


if _cod_tipopago = '003' or _estatus = "Declinado" then
   return         _fecha_factura,
                  _pagado,
                  _estatus,
                  _numrecla,
                  _facturado,
                  _gasto_eleg,
                  _deducible,
                  _co_pago,
                  _coaseguro,
                  _monto,
                  _gastos_no_cub,
                  _no_cheque,
                  _transaccion,
                  _cod_entrada, --no_bloque
                  _cod_asignacion,
                  _cod_icd,
                  _tipotran,
                  _pago_prov,
		          _gasto_eleg, 
				  _cod_tipopago	with resume;

end if
end foreach

-- si no quiere decir que la busqueda es por dependiente
else
 	foreach

  SELECT fecha_factura,
					pagado,
					recrcmae.numrecla,
					facturado,
					elegible,
					a_deducible,
					co_pago,
					coaseguro,
					rectrmae.monto,
					cod_tipotran,
					no_tranrec,
					no_requis,
					recrcmae.no_reclamo,
					rectrmae.cod_asignacion,
					rectrmae.transaccion,
					recrcmae.cod_icd,
                    cod_tipopago					
			 into _fecha_factura,
                  _pagado,
                  _numrecla,
                  _facturado,
                  _elegible,
                  _deducible,
                  _co_pago,
                  _coaseguro,
                  _monto,
                  _tipotran,
                  _no_tranrec,
                  _no_requis,
                  _no_reclamo,
                  _cod_asignacion,
                  _transaccion,
                  _cod_icd,
				  _cod_tipopago
             FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
	  --			  /*inner join atcdocde on atcdocde.cod_asignacion = recrcmae.cod_asignacion*/
             where recrcmae.cod_compania = "001"
             and recrcmae.actualizado  = 1
             and rectrmae.periodo like "%"||a_periodo||"%" 
			 -- antes era matches 
	--		 /*a_periodo*/
             and cod_tipotran in ('013', '004')
  --			 /*and rectrmae.cod_tipopago = '003' /*pago a Asegurados*/
             and anular_nt    is null
			 and rectrmae.transaccion is not null
             and recrcmae.no_documento = a_no_documento
             order by fecha_factura DESC

		   
	let _no_cheque = 0; 
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
							 
						else
						
						  let _estatus = "En Proceso";
						  
						end if
						
					else
					
							if _monto = '0.00' then
							
								let _estatus = "A Deducible";
								
							else
							
								let _estatus = "En Proceso";
								
							end if
							
					end if -- fin de pagado tabla rectrmae

	end if --fin del if de 013 declinado


		 select	facturado,
		        elegible,
			   	a_deducible,
				co_pago,
				coaseguro,
				monto,
				monto_no_cubierto
		  into	_facturado,
		        _gasto_eleg,
				_deducible,
				_co_pago,
				_coaseguro,
				_pago_prov,
				_gastos_no_cub
		  from rectrcob
		  where no_tranrec = _no_tranrec; 

		 select cod_entrada
		 into  _cod_entrada
		 from atcdocde
		 where cod_asignacion = _cod_asignacion;


		if _cod_tipopago = '003' or _estatus = "Declinado" then
		   return         _fecha_factura,
						  _pagado,
						  _estatus,
						  _numrecla,
						  _facturado,
						  _gasto_eleg,
						  _deducible,
						  _co_pago,
						  _coaseguro,
						  _monto,
						  _gastos_no_cub,
						  _no_cheque,
						  _transaccion,
						  _cod_entrada, --no_bloque
						  _cod_asignacion,
						  _cod_icd,
						  _tipotran,
						  _pago_prov,
						  _gasto_eleg, 
						  _cod_tipopago	with resume;

		end if
	end foreach
end if

end procedure                                