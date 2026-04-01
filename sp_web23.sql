-- Obtener el estado de los reclamos el modulo web de consulta corredores para reclamos

-- Creado: 19/05/2013 - Autor: Enocjahaziel Carrasco

-- SIS - Pagina Web consulta de el estado de los reclamos modulo de los corredores consultas web.

drop procedure sp_web23;

create procedure "informix".sp_web23( a_cod_agente varchar(10),a_bloque varchar(10),a_num_recla varchar(20), ano_corte integer)
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
char(3),
integer,
varchar(20),
varchar(20),
varchar(20),
varchar(20);

define _no_reclamo varchar(20);
define _cod_asignacion varchar(20);
define _fecha_factura date;
define _fecha	date;
define _tipotran varchar(10);
define _no_requis varchar(20);
define _numrecla varchar(20);

define _no_documento varchar(20);
define _no_cedula varchar(20);
define _no_unidad varchar(20);

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
define _cod_cobertura varchar(10);
define _caso integer;
--let _fecha   = today;
--let _fecha   = _fecha - 10 units month;
--let _periodo = sp_sis39(_fecha);
let _no_cheque = 0;
let _wf_pagado = 0;

set isolation to dirty read;
--SET DEBUG FILE TO "sp_web23.trc"; 
--TRACE ON;
 --if a_num_recla = '' then
   -- let _caso = 0;       
   --end if
 if a_bloque <> '' and a_num_recla = ''  then
    let _caso = 1;       
	else 
	if a_bloque  = '' and a_num_recla <> ''  then
	let _caso = 2;
	else 
	let _caso = 3;
	end if 	
 end if   
-- busqueda por no_poliza si en valor de cod_reclamante es nulo 

 if _caso = 1 then
 let _no_requis = 0;
 foreach
 SELECT fecha_factura, --1
			pagado,--2 
			recrcmae.numrecla,--3
			rectrmae.facturado,--4
			elegible,--5
			a_deducible,--6
			co_pago,--7
			coaseguro,--8
			rectrmae.monto,--9
			cod_tipotran,--10
			no_tranrec,--11
			no_requis,--12
			recrcmae.no_reclamo,--13
			rectrmae.cod_asignacion,--14
			rectrmae.transaccion,--15
			recrcmae.cod_icd,--16
             rectrmae.cod_tipopago,		--17
			 emipomae.no_documento, --18
			cliclien.cedula, --19
            recrcmae.no_unidad --20
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
				  _cod_tipopago,
				  _no_documento,
				 _no_cedula,
				 _no_unidad
             FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
			 inner join emipoagt on recrcmae.no_poliza = emipoagt.no_poliza
			 inner join emipomae on recrcmae.no_poliza = emipomae.no_poliza
			 inner join cliclien on recrcmae.cod_reclamante = cliclien.cod_cliente
	         inner join  atcdocde  on recrcmae.no_documento = atcdocde.no_documento and   atcdocde.cod_asignacion =rectrmae.cod_asignacion
             where recrcmae.cod_compania = "001"
			 and cod_ramo = '018'
             and recrcmae.actualizado  = 1
             and cod_tipotran in ('013', '004')
             and anular_nt    is null
			 and rectrmae.transaccion is not null
			 and rectrmae.cod_asignacion is not null
			 and rectrmae.cod_asignacion <> ''
			 and   cod_agente = a_cod_agente
			 and atcdocde.cod_entrada = a_bloque
			 and year(rectrmae.fecha) = ano_corte
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

foreach
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
		  where no_tranrec = _no_tranrec
		 

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
				  _cod_tipopago,
				  _wf_pagado,
				  _no_requis,
				  _no_documento,
				  _no_cedula,
				  _no_unidad
				  with resume;

 end if
 end foreach
 end foreach                            
 end if
  if _caso = 2 then
  let _no_requis = 0;
   foreach
  SELECT fecha_factura, --1
			pagado,--2 
			recrcmae.numrecla,--3
			rectrmae.facturado,--4
			elegible,--5
			a_deducible,--6
			co_pago,--7
			coaseguro,--8
			rectrmae.monto,--9
			cod_tipotran,--10
			no_tranrec,--11
			no_requis,--12
			recrcmae.no_reclamo,--13
			rectrmae.cod_asignacion,--14
			rectrmae.transaccion,--15
			recrcmae.cod_icd,--16
             rectrmae.cod_tipopago,		--17
			emipomae.no_documento, --18
			cliclien.cedula, --19
            recrcmae.no_unidad --20			 
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
				  _cod_tipopago,
				  _no_documento,
				 _no_cedula,
				 _no_unidad
             FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
			 inner join emipoagt on recrcmae.no_poliza = emipoagt.no_poliza
			 inner join emipomae on recrcmae.no_poliza = emipomae.no_poliza
			 inner join cliclien on recrcmae.cod_reclamante = cliclien.cod_cliente
	         inner join  atcdocde  on recrcmae.no_documento = atcdocde.no_documento and   atcdocde.cod_asignacion = recrcmae.cod_asignacion
             where recrcmae.cod_compania = "001"
			 and cod_ramo = '018'
             and recrcmae.actualizado  = 1
             and cod_tipotran in ('013', '004')
             and anular_nt    is null
			 and rectrmae.transaccion is not null
			 and rectrmae.cod_asignacion is not null
			 and rectrmae.cod_asignacion <> ''
			 and   cod_agente = a_cod_agente		
			 and recrcmae.numrecla = a_num_recla
			 and year(rectrmae.fecha) = ano_corte
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

foreach
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
		  where no_tranrec = _no_tranrec
		 

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
				  _cod_tipopago,
				  _wf_pagado ,
                  _no_requis,
				  _no_documento,
				  _no_cedula,
				  _no_unidad
				  with resume;

end if
end foreach
end foreach
                              
 end if
  if _caso = 3 then
  let _no_requis = 0;
 foreach
   SELECT fecha_factura, --1
			pagado,--2 
			recrcmae.numrecla,--3
			rectrmae.facturado,--4
			elegible,--5
			a_deducible,--6
			co_pago,--7
			coaseguro,--8
			rectrmae.monto,--9
			cod_tipotran,--10
			no_tranrec,--11
			no_requis,--12
			recrcmae.no_reclamo,--13
			rectrmae.cod_asignacion,--14
			rectrmae.transaccion,--15
			recrcmae.cod_icd,--16
            rectrmae.cod_tipopago, --17					
            emipomae.no_documento, --18
			cliclien.cedula, --19
            recrcmae.no_unidad --20
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
				  _cod_tipopago,
				 _no_documento,
				 _no_cedula,
				 _no_unidad
             FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
			 inner join emipoagt on recrcmae.no_poliza = emipoagt.no_poliza
			 inner join emipomae on recrcmae.no_poliza = emipomae.no_poliza
			 inner join cliclien on recrcmae.cod_reclamante = cliclien.cod_cliente
	         inner join  atcdocde  on recrcmae.no_documento = atcdocde.no_documento and   atcdocde.cod_asignacion =rectrmae.cod_asignacion
             where recrcmae.cod_compania = "001"
			 and cod_ramo = '018'
             and recrcmae.actualizado  = 1
             and cod_tipotran in ('013', '004')
             and anular_nt    is null
			 and rectrmae.transaccion is not null
			 and rectrmae.cod_asignacion is not null
			 and rectrmae.cod_asignacion <> ''
			 and   cod_agente = a_cod_agente		
			 and year(rectrmae.fecha) = ano_corte
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

foreach
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
		  where no_tranrec = _no_tranrec
		 

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
				  _cod_tipopago,
				  _wf_pagado,
				  _no_requis,
				  _no_documento,
				  _no_cedula,
				  _no_unidad
				  with resume;

end if
end foreach
end foreach                            
 end if
	end procedure