-- Obtener el estado de los reclamos el modulo web de consulta corredores

-- Creado: 29/11/2011 - Autor: Federico Coronado

-- SIS - Pagina Web consulta de el estado de los reclamos modulo de los corredores consultas web.

drop procedure sp_web10aa;

create procedure "informix".sp_web10aa(a_no_documento char(20), a_cod_reclamante varchar(20), _no_tramite_busca varchar(10) default null, _no_factura_busca varchar(10) default null)
returning char(20),
varchar(20),
varchar(60),
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
varchar(50),
varchar(50),
date,
varchar(10),
varchar(5),
varchar(70),
varchar(10);

define _no_reclamo 			varchar(20);
define _cod_asignacion 		varchar(20);
define _fecha_factura 		date;
define _fecha				date;
define _tipotran 			varchar(10);
define _no_requis 			varchar(20);
define _numrecla 			varchar(20);

define _periodo				varchar(7);
define _no_cheque 			varchar(10);
define _pagado 				char(10);
define _cod_entrada 		char(10);

define _estatus				varchar(60);
define _no_tranrec 			varchar(10);
define _transaccion 		varchar(10);

define _wf_pagado 			integer;
define _wf_entregado 		integer;
define _en_firma 			smallint;
define _wf_fecha 			char(10);
define _wf_nombre 			char(30);
define _wf_cedula 			char(10);
define _cod_icd 			char(10);

define _monto 				decimal(10,2);
define _gastos_no_cub 		decimal(10,2);
define  _facturado 			decimal(10,2);
define _elegible 			decimal(10,2);
define _deducible 			decimal(10,2);
define _co_pago 			decimal(10,2);
define _coaseguro 			decimal(10,2);
define _pago_prov 			decimal(10,2);
define _gasto_eleg 			decimal(10,2);
define _gasto_fact 			decimal(10,2);
define _cod_tipopago 		char(3);
define _nombre_asegurado	varchar(50);
define _nombre_reclamante 	varchar(50);
define _cod_reclamante		char(10);
define _cod_asegurado 		char(10); 
define _fecha_siniestro		date;
define _no_poliza           varchar(10);
define _no_unidad           varchar(5);   
define _no_tramite   		varchar(10);
define _cod_ramo  		    varchar(3);
define _ajust_interno  		varchar(3);
define _cod_cliente 		varchar(20);
define _count_atcdocde 		integer;
define _count_recterce 		integer;
define _mensaje             varchar(70);
define _desc_nota           varchar(70);
define _cod_taller       	varchar(10);
define _nombre_taller       varchar(70);
define _nombre_ajustador    varchar(70);
define _concept_pago        varchar(3);
define _no_factura       	varchar(10);
define _count_codasignacion integer;
define _count_chqchmae 		integer;
define _anulado				integer;

--set debug file to "sp_web10a.trc";
--trace on;

let _fecha   = today;
let _fecha   = _fecha - 730 units day;
/*let _periodo = sp_sis39(_fecha);*/

let _no_requis = 0;
let _no_cheque = 0;
let _wf_pagado = 0;
let _cod_tipopago = '';
let _fecha_factura = '';
let _pagado = '';
let _estatus = '--';
let _numrecla = '';
let _facturado = '';
let _gasto_eleg = '';
let _deducible = '';
let _co_pago = '';
let _coaseguro = '';
let _monto = '';
let _gastos_no_cub = '';
let _no_cheque = '';
let _transaccion = '';
let _cod_entrada = '';
let _cod_asignacion = '';
let _cod_icd = '';
let _tipotran = '';
let _pago_prov = '';
let _gasto_eleg = '';
let _wf_pagado = '';
let _no_requis = '';
let _nombre_asegurado = '';
let _nombre_reclamante = '';
let _fecha_siniestro = '';
let _no_poliza = '';
let _no_unidad = '';
let _no_tranrec = '';
let _ajust_interno = '';
let _mensaje = '';
let _no_factura = '';

set isolation to dirty read;

let _no_poliza = sp_sis21(a_no_documento);

select cod_ramo
	into _cod_ramo
from emipomae
	where no_poliza = _no_poliza;
  
select cod_cliente
	into _cod_cliente
from cliclien
	where cedula = a_cod_reclamante;
	
select count(*)
	into _count_recterce
from recrcmae a
inner join recterce b on a.no_reclamo = b.no_reclamo
	where a.no_tramite = _no_tramite_busca
	and b.cod_tercero = _cod_cliente;
	
if trim(_no_tramite_busca) <> '' then --BUSQUEDA POR NO TRAMITE
	if _count_recterce > 0 then --BUSQUEDA POR NO TRAMITE PARA TERCEROS**
	
		foreach 
			select 
			c.nombre, 
			a.numrecla,
			d.nombre,
			e.cod_tipopago,
			e.cod_tipotran,
			e.no_requis
		INTO 
			_nombre_asegurado,
			_numrecla,
			_nombre_ajustador,
			_cod_tipopago,
			_tipotran,
			_no_requis
			from recrcmae a
			inner join recterce b on a.no_reclamo = b.no_reclamo
			inner join cliclien c on b.cod_tercero = c.cod_cliente
			--inner join recajust d on b.user_changed = d.cod_ajustador
			inner join recajust d on a.ajust_interno = d.cod_ajustador 
			inner join rectrmae e on a.no_reclamo = e.no_reclamo
			where a.no_tramite = _no_tramite_busca
			and b.cod_tercero = _cod_cliente
			and e.actualizado = 1
			order by e.fecha desc
		exit foreach;
		end foreach
		
		if _nombre_ajustador <> '' AND _tipotran = '001' then
			let _estatus = 'Abierto';
			let _mensaje = 'Su reclamo ha sido recibido asignado a ajustador: '||_nombre_ajustador;
		end if
		
		if _nombre_ajustador <> '' AND _tipotran = '002' or _tipotran = '003' then
			let _estatus = 'En tramite';
			let _mensaje = 'Su reclamo se encuentra en análisis.';
		end if
		
		if _nombre_ajustador <> '' AND _tipotran = '013' then
			let _estatus = 'Declinado';
			let _mensaje = 'Su reclamo fue declinado.';
		end if
		
		if _nombre_ajustador <> '' AND _tipotran = '004' AND _cod_tipopago = '004' AND _no_requis <> '' then
			let _estatus = 'En proceso';
			let _mensaje = 'En proceso de desembolso.';
		end if
		
		if _nombre_ajustador <> '' AND _tipotran = '004' AND _cod_tipopago = '004' AND _no_requis <> '' AND _pagado = 1 then
			let _estatus = 'Pagado';
			let _mensaje = 'Su reclamo ha sido pagado.';
		end if
		
		if _nombre_ajustador <> '' AND _tipotran = '011' then 
		
			SELECT no_cheque, wf_entregado, a.pagado, anulado
				INTO _no_cheque,
					_wf_entregado,
					_pagado,
					_anulado
			FROM chqchmae a
			inner join rectrmae b on a.no_requis = b.no_requis
				WHERE a.cod_cliente = _cod_cliente
				AND b.numrecla = _numrecla;
					
				if _no_cheque = '0' then
					let _estatus = 'En proceso';
					let _mensaje = 'En proceso de desembolso.';
				end if	
				
				if _no_cheque <> '0' AND _pagado = 1 AND _anulado = 0 then
					let _estatus = 'Pagado';
					let _mensaje = 'Su pago ha sido enviado. Cheque/ACH: '||_no_cheque;
				end if	
				
				if _wf_entregado = 1 then
					let _estatus = 'Cerrado';
					let _mensaje = 'Su reclamo fue cerrado.';
				end if	
		end if
			
			return 
			  _fecha_factura,
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
			  _nombre_asegurado,
			  _nombre_reclamante,
			  _fecha_siniestro,
			  _no_poliza,
			  _no_unidad,
			  _mensaje,
			  _no_factura
			  with resume;
		

	else --BUSQUEDA POR NO TRAMITE PARA ASEGURADOS**
		select count(*) 
			into _count_atcdocde
		from atcdocde
			where cod_entrada = _no_tramite_busca 
			and (cod_asegurado = _cod_cliente OR cod_reclamante = _cod_cliente);

		if _count_atcdocde = 0 then --AUTOMOVIL POR NO TRAMITE
			foreach
			 SELECT recrcmae.numrecla,
					recrcmae.no_reclamo,
					recrcmae.cod_icd,
					cod_reclamante,
					cod_asegurado,
					fecha_siniestro,
					no_poliza,
					no_unidad,
					no_tramite,
					ajust_interno,
					cod_taller
			 into 
				  _numrecla,
				  _no_reclamo,
				  _cod_icd,
				  _cod_reclamante,
				  _cod_asegurado,
				  _fecha_siniestro,
				  _no_poliza,
				  _no_unidad,
				  _no_tramite,
				  _ajust_interno,
				  _cod_taller
			 FROM recrcmae 
			 where recrcmae.cod_compania = "001"
			 and recrcmae.actualizado  = 1
			 and recrcmae.no_tramite = _no_tramite_busca
			 and (recrcmae.cod_reclamante = _cod_cliente or recrcmae.cod_asegurado = _cod_cliente)
			 and fecha_reclamo >= _fecha
			
			foreach	
				 SELECT fecha_factura,
						pagado,
						facturado,
						elegible,
						a_deducible,
						co_pago,
						coaseguro,
						rectrmae.monto,
						cod_tipotran,
						no_tranrec,
						no_requis,
						rectrmae.cod_asignacion,
						rectrmae.transaccion,
						cod_tipopago
				 into _fecha_factura,
					  _pagado,
					  _facturado,
					  _elegible,
					  _deducible,
					  _co_pago,
					  _coaseguro,
					  _monto,
					  _tipotran,
					  _no_tranrec,
					  _no_requis,
					  _cod_asignacion,
					  _transaccion,
					  _cod_tipopago
				 FROM rectrmae
				 where cod_tipotran in ('001','002','004','007','011','013')
				 and anular_nt  is null
				 and rectrmae.transaccion is not null
				 and no_reclamo = _no_reclamo
				 order by fecha desc
				 exit foreach;
			end foreach 

			 select nombre
			   into _nombre_asegurado
			   from cliclien
			  where cod_cliente = _cod_cliente;
			 
			 select nombre
			   into _nombre_reclamante
			   from cliclien
			  where cod_cliente = _cod_cliente;
			  
			  select	sum(facturado),
						sum(elegible),
						sum(a_deducible),
						sum(co_pago),
						sum(coaseguro),
						sum(monto),
						sum(monto_no_cubierto)
				into	_facturado,
						_gasto_eleg,
						_deducible,
						_co_pago,
						_coaseguro,
						_pago_prov,
						_gastos_no_cub
				from rectrcob
			   where no_tranrec = _no_tranrec; 

				if _cod_asignacion is null or trim(_cod_asignacion) = '' then
					let _cod_entrada = _no_tramite;
				end if
				
				SELECT count(*)
					INTO _desc_nota
				FROM recnotas 
				WHERE no_reclamo = _no_reclamo 
				AND desc_nota like '%ASEGURADO PUEDE PAGAR DEDUCIBLE%';

			if _cod_tipopago in('001','002') then
				SELECT cod_concepto
					INTO _concept_pago
				FROM rectrcon WHERE no_tranrec = _no_tranrec;
			end if
			
			if _ajust_interno <> '' AND _tipotran = '001' then
				SELECT nombre
					INTO _nombre_ajustador
				FROM recajust 
					WHERE cod_ajustador = _ajust_interno;
				let _estatus = 'Abierto';
				let _mensaje = 'Su reclamo ha sido recibido asignado a Ajustador: '||_nombre_ajustador;
			end if
			
			if _ajust_interno <> '' AND _tipotran = '002' or _tipotran = '003' then
				let _estatus = 'En tramite';
				let _mensaje = 'Su reclamo se encuentra en cotización y análisis.';
			end if
			
			if _ajust_interno <> '' AND _tipotran IN('001','002','003') AND _desc_nota > 0 then
				let _estatus = 'Pago de Deducible';
				let _mensaje = 'Asegurado puede pagar deducible.';
			end if
			
			if _ajust_interno <> '' AND _tipotran = '013' then
				let _estatus = 'Declinado';
				let _mensaje = 'Su reclamo fue declinado.';
			end if

			if _ajust_interno <> '' AND _tipotran = '007' then
				let _estatus = 'En Proceso';
				let _mensaje = 'En proceso de emisión de ordenes de reparación.';
			end if
			--aqui***
			if _ajust_interno <> '' AND _tipotran = '004' AND _cod_tipopago in('001','002') AND _concept_pago in('017','003','013') then
				SELECT nombre 
					INTO _nombre_taller
				FROM cliclien 
					where cod_cliente = _cod_taller;
				let _estatus = 'Ordenes emitidas';
				let _mensaje = 'Ordenes de reparacion emitidas. Favor comunicarse con: '||_nombre_taller;
			end if

			if _ajust_interno <> '' AND _tipotran = '004' AND _cod_tipopago = '003' AND _no_requis <> '' then
				let _estatus = 'En proceso';
				let _mensaje = 'En proceso de desembolso.';
			end if
			
			if _ajust_interno <> '' AND _tipotran = '004' AND _cod_tipopago in('002','001') AND _no_requis <> '' AND _concept_pago in('012','022','003','013') then
				let _estatus = 'Completado';
				let _mensaje = 'Su reclamo ha sido completado.';
			end if
			--aqui***
			if _ajust_interno <> '' AND _tipotran = '004' AND _cod_tipopago = '003' AND _no_requis <> '' AND _pagado = 1 then
				let _estatus = 'Pagado';
				let _mensaje = 'Su reclamo ha sido pagado.';
			end if
			
			if _ajust_interno <> '' AND _tipotran = '011' then
				let _estatus = 'Cerrado';
				let _mensaje = 'Su reclamo fue cerrado.';
				
				SELECT no_cheque, wf_entregado, a.pagado, anulado
					INTO _no_cheque,
						_wf_entregado,
						_pagado,
						_anulado
				FROM chqchmae a
				inner join rectrmae b on a.no_requis = b.no_requis
				WHERE a.cod_cliente = _cod_cliente
				AND b.numrecla = _numrecla;
			
					if _no_cheque = '0' then
						let _estatus = 'En proceso';
						let _mensaje = 'En proceso de desembolso.';
					end if	
					
					if _no_cheque <> '0' AND _pagado = 1 AND _anulado = 0 then
						let _estatus = 'Pagado';
						let _mensaje = 'Su pago ha sido enviado. Cheque/ACH: '||_no_cheque;
					end if	
					
					if _wf_entregado = 1 then
						let _estatus = 'Cerrado';
						let _mensaje = 'Su reclamo fue cerrado.';
					end if	
			
			end if
				
				return _fecha_factura,
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
					  _nombre_asegurado,
					  _nombre_reclamante,
					  _fecha_siniestro,
					  _no_poliza,
					  _no_unidad,
					  _mensaje,
					  _no_factura
					  with resume;
			
				end foreach
				
		else --SALUD POR NO TRAMITE
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
				rectrmae.cod_tipopago,
				recrcmae.cod_reclamante,
				recrcmae.cod_asegurado,
				fecha_siniestro,
				no_poliza,
				recrcmae.no_unidad,
				no_tramite,
				ajust_interno
			INTO _fecha_factura,
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
				_cod_reclamante,
				_cod_asegurado,
				_fecha_siniestro,
				_no_poliza,
				_no_unidad,
				_no_tramite,
				_ajust_interno
		 FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
		 inner join atcdocde on atcdocde.cod_asignacion = rectrmae.cod_asignacion
		 where recrcmae.cod_compania = "001"
		 and recrcmae.actualizado  = 1
		 and cod_tipotran in ('013', '004','007')
		 and anular_nt    is null
		 and rectrmae.transaccion is not null
		 and (rectrmae.cod_tipopago = '003' or (recrcmae.cod_asegurado = recrcmae.cod_reclamante AND cod_tipotran = '013'))
		 and atcdocde.cod_entrada = _no_tramite_busca
		 and rectrmae.no_factura = _no_factura_busca
		 and (recrcmae.cod_reclamante = _cod_cliente or recrcmae.cod_asegurado = _cod_cliente)
		 and fecha_factura >= _fecha
		 order by fecha_factura DESC

		 select nombre
			   into _nombre_asegurado
			   from cliclien
			  where cod_cliente = _cod_cliente;
			 
			 select nombre
			   into _nombre_reclamante
			   from cliclien
			  where cod_cliente = _cod_cliente;
			  
			  select	sum(facturado),
						sum(elegible),
						sum(a_deducible),
						sum(co_pago),
						sum(coaseguro),
						sum(monto),
						sum(monto_no_cubierto)
				into	_facturado,
						_gasto_eleg,
						_deducible,
						_co_pago,
						_coaseguro,
						_pago_prov,
						_gastos_no_cub
				from rectrcob
			   where no_tranrec = _no_tranrec; 
				
			if _ajust_interno = '' then
				let _estatus = 'Abierto';
				let _mensaje = 'Su reclamo ha sido recibido.';
			end if
				
			if _ajust_interno <> '' AND _tipotran = '' then
				let _estatus = 'En trámite';
				let _mensaje = 'Su reclamo ya se encuentra en análisis.';
			end if
			
			if _ajust_interno <> '' AND _tipotran = '007' then
				let _estatus = 'Aplica Deducible';
				let _mensaje = 'Su trámite aplicó a deducible.';
			end if
			
			if _ajust_interno <> '' AND _tipotran = '013' then
				let _estatus = 'Declinado';
				let _mensaje = 'Su reclamo fue declinado.';
			end if
			
			if _ajust_interno <> '' AND _tipotran = '004' AND _pagado = 0 then
				let _estatus = 'En Proceso';
				let _mensaje = 'En proceso de desembolso.';
					if _monto = '0.00' then
						let _estatus = "Aplica Deducible";
						let _mensaje = 'Su trámite aplicó a deducible.';
					end if	
			end if
			
			if _ajust_interno <> '' AND _tipotran = '004' AND _pagado = 1 then
				let _estatus = 'Pagado';
				SELECT no_cheque
				  into _no_cheque
				FROM chqchmae
				  where no_requis = _no_requis;
				let _mensaje = 'Su pago ha sido enviado. Cheque/ACH: '||_no_cheque;
			end if
				
				return _fecha_factura,
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
					  _nombre_asegurado,
					  _nombre_reclamante,
					  _fecha_siniestro,
					  _no_poliza,
					  _no_unidad,
					  _mensaje,
					  _no_factura
					  with resume;
		end foreach
	end if --TERMINA IF SI RECTERCE <> 0
end if --TERMINA IF PARA BUSQUEDA POR TRAMITE
	
elif trim(_cod_ramo) in('002','020','023') then --BUSQUEDA POR NO DOCUMENTO AUTOMOVIL
foreach
	 SELECT recrcmae.numrecla,
			recrcmae.no_reclamo,
			recrcmae.cod_icd,
			cod_reclamante,
			cod_asegurado,
			fecha_siniestro,
			no_poliza,
			no_unidad,
			no_tramite,
			ajust_interno
	 into 
		  _numrecla,
		  _no_reclamo,
		  _cod_icd,
		  _cod_reclamante,
		  _cod_asegurado,
		  _fecha_siniestro,
		  _no_poliza,
		  _no_unidad,
		  _no_tramite,
		  _ajust_interno
	 FROM recrcmae 
	 where recrcmae.cod_compania = "001"
	 and recrcmae.actualizado  = 1
	 and recrcmae.no_documento = a_no_documento
	 and (recrcmae.cod_reclamante = a_cod_reclamante or recrcmae.cod_asegurado = a_cod_reclamante)
	 and fecha_reclamo >= _fecha
	
foreach	
	 SELECT fecha_factura,
			pagado,
			facturado,
			elegible,
			a_deducible,
			co_pago,
			coaseguro,
			rectrmae.monto,
			cod_tipotran,
			no_tranrec,
			no_requis,
			rectrmae.cod_asignacion,
			rectrmae.transaccion,
			cod_tipopago
	 into _fecha_factura,
		  _pagado,
		  _facturado,
		  _elegible,
		  _deducible,
		  _co_pago,
		  _coaseguro,
		  _monto,
		  _tipotran,
		  _no_tranrec,
		  _no_requis,
		  _cod_asignacion,
		  _transaccion,
		  _cod_tipopago
	 FROM rectrmae
	 where cod_tipotran in ('001','002','004','007','011','013')
	 and anular_nt  is null
	 and rectrmae.transaccion is not null
	 and no_reclamo = _no_reclamo
	 order by fecha desc
	 exit foreach;
end foreach 

	 select nombre
	   into _nombre_asegurado
	   from cliclien
	  where cod_cliente = _cod_asegurado;
	 
	 select nombre
	   into _nombre_reclamante
	   from cliclien
	  where cod_cliente = _cod_reclamante;
	  
	  select	sum(facturado),
				sum(elegible),
				sum(a_deducible),
				sum(co_pago),
				sum(coaseguro),
				sum(monto),
				sum(monto_no_cubierto)
		into	_facturado,
				_gasto_eleg,
				_deducible,
				_co_pago,
				_coaseguro,
				_pago_prov,
				_gastos_no_cub
		from rectrcob
	   where no_tranrec = _no_tranrec; 
	   
	   if _cod_asignacion is null or trim(_cod_asignacion) = '' then
			let _cod_entrada = _no_tramite;
		else
			select cod_entrada
			  into _cod_entrada
			  from atcdocde
			 where cod_asignacion = _cod_asignacion;
		end if
		
		SELECT count(*)
				INTO _desc_nota
			FROM recnotas 
			WHERE no_reclamo = _no_reclamo 
			AND desc_nota like '%ASEGURADO PUEDE PAGAR DEDUCIBLE%';

		SELECT cod_concepto
			INTO _concept_pago
		FROM rectrcon WHERE no_tranrec = _no_tranrec;
		
		if _ajust_interno <> '' AND _tipotran = '001' then
			let _estatus = 'Abierto';
		end if
		
		if _ajust_interno <> '' AND _tipotran = '002' or _tipotran = '003' then
			let _estatus = 'En tramite';
		end if
		
		if _ajust_interno <> '' AND _tipotran IN('001','002','003') AND _desc_nota > 0 then
			let _estatus = 'Pago de Deducible';
		end if
		
		if _ajust_interno <> '' AND _tipotran = '013' then
			let _estatus = 'Declinado';
		end if

		if _ajust_interno <> '' AND _tipotran = '007' then
			let _estatus = 'En Proceso de Emision de Ordenes de Reparacion';
		end if
		
		if _ajust_interno <> '' AND _tipotran = '004' AND _cod_tipopago in('001','002') AND _concept_pago in('017','003','013') then
			let _estatus = 'Emitidas Ordenes de Reparacion';
		end if
		
		if _ajust_interno <> '' AND _tipotran = '004' AND _cod_tipopago in('003','004') AND _no_requis <> '' then
			let _estatus = 'Generando pago';
		end if
		
		if _ajust_interno <> '' AND _tipotran = '004' AND _cod_tipopago in('002','001') AND _no_requis <> '' AND _concept_pago in('012','022','003','013') then
			let _estatus = 'Completado';
		end if
		
		if _ajust_interno <> '' AND _tipotran = '004' AND _cod_tipopago in('003','004') AND _no_requis <> '' AND _pagado = 1 then
			let _estatus = 'Pagado';
		end if
		
		if _ajust_interno <> '' AND _tipotran = '011' then
		
			let _estatus = 'Cerrado';
				
			SELECT no_cheque, wf_entregado, a.pagado, anulado
				INTO _no_cheque,
					_wf_entregado,
					_pagado,
					_anulado
			FROM chqchmae a
			inner join rectrmae b on a.no_requis = b.no_requis
			WHERE a.cod_cliente = a_cod_reclamante
			AND b.numrecla = _numrecla;
		
				if _no_cheque = '0' then
					let _estatus = 'En proceso';
				end if	
				
				if _no_cheque <> '0' AND _pagado = 1 AND _anulado = 0 then
					let _estatus = 'Pagado';
				end if	
				
				if _wf_entregado = 1 then
					let _estatus = 'Cerrado';
				end if
					
			end if
		
		
		return _fecha_factura,
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
			  _nombre_asegurado,
			  _nombre_reclamante,
			  _fecha_siniestro,
			  _no_poliza,
			  _no_unidad,
			  _mensaje,
			  _no_factura
			  with resume;
	
end foreach

elif trim(_cod_ramo) in ('004','016','018','019') then --BUSQUEDA POR NO DOCUMENTO SALUD

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
			cod_tipopago,
			cod_reclamante,
			cod_asegurado,
			fecha_siniestro, 
			no_poliza,
			no_unidad,
			no_tramite,
			ajust_interno,
			rectrmae.no_factura
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
		  _cod_reclamante,
		  _cod_asegurado,
		  _fecha_siniestro,
		  _no_poliza,
		  _no_unidad,
		  _no_tramite,
		  _ajust_interno,
		  _no_factura
	 FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
	 where recrcmae.cod_compania = "001"
	 and recrcmae.actualizado  = 1
	 and cod_tipotran in ('013', '004','007')
	 and anular_nt    is null
	 and rectrmae.transaccion is not null
	 and (rectrmae.cod_tipopago = '003' or (cod_asegurado = cod_reclamante AND cod_tipotran = '013'))
	 and recrcmae.no_documento = a_no_documento
	 and (recrcmae.cod_reclamante = a_cod_reclamante or recrcmae.cod_asegurado = a_cod_reclamante)
	 and fecha_factura >= _fecha
	 order by fecha_factura DESC

	 select nombre
	   into _nombre_asegurado
	   from cliclien
	  where cod_cliente = _cod_asegurado;
	 
	 select nombre
	   into _nombre_reclamante
	   from cliclien
	  where cod_cliente = _cod_reclamante;
	  
	  select	sum(facturado),
				sum(elegible),
				sum(a_deducible),
				sum(co_pago),
				sum(coaseguro),
				sum(monto),
				sum(monto_no_cubierto)
		into	_facturado,
				_gasto_eleg,
				_deducible,
				_co_pago,
				_coaseguro,
				_pago_prov,
				_gastos_no_cub
		from rectrcob
	   where no_tranrec = _no_tranrec; 

		if _cod_asignacion is null or trim(_cod_asignacion) = '' then
			let _cod_entrada = _no_tramite;
		else
			select cod_entrada
			  into _cod_entrada
			  from atcdocde
			 where cod_asignacion = _cod_asignacion;
		end if
		
		
		if _ajust_interno = '' then
			let _estatus = 'Abierto';
			let _mensaje = 'Su reclamo ha sido recibido.';
		end if
			
		if _ajust_interno <> '' AND _tipotran = '' then
			let _estatus = 'En tramite';
			let _mensaje = 'Su reclamo ya se encuentra en análisis.';
		end if
		
		if _ajust_interno <> '' AND _tipotran = '007' then
			let _estatus = 'Aplica Deducible';
			let _mensaje = 'Su trámite aplicó a deducible.';
		end if
		
		if _ajust_interno <> '' AND _tipotran = '013' then
			let _estatus = 'Declinado';
			let _mensaje = 'Su reclamo fue declinado.';
		end if
		
		if _ajust_interno <> '' AND _tipotran = '004' AND _pagado = 0 then
			let _estatus = 'En Proceso';
			let _mensaje = 'En proceso de desembolso.';
				if _monto = '0.00' then
					let _estatus = "Aplica Deducible";
					let _mensaje = 'Su trámite aplicó a deducible.';
				end if	
		end if
		
		if _ajust_interno <> '' AND _tipotran = '004' AND _pagado = 1 then
			let _estatus = 'Pagado';
			SELECT no_cheque
			  into _no_cheque
			FROM chqchmae
			  where no_requis = _no_requis;
			let _mensaje = 'Su pago ha sido enviado. Cheque/ACH: '||_no_cheque;
		end if
		
		if trim(_no_factura_busca) = '' OR _no_factura_busca is null then --FLUJO NORMAL CUANDO ES POR SALUD
			return _fecha_factura,
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
			  _nombre_asegurado,
			  _nombre_reclamante,
			  _fecha_siniestro,
			  _no_poliza,
			  _no_unidad,
			  _mensaje,
			  _no_factura
			  with resume;
			 else
				if _no_factura_busca = _cod_entrada then -- CUANDO SE LLAMA DESDE CHATBOT PRUDENCIA (SE SOLICITA EL BLOQUE)
					return _fecha_factura,
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
					  _nombre_asegurado,
					  _nombre_reclamante,
					  _fecha_siniestro,
					  _no_poliza,
					  _no_unidad,
					  _mensaje,
					  _no_factura
					  with resume;
				end if	
		end if
	end foreach
	
let _no_requis = 0;
let _no_cheque = 0;
let _wf_pagado = 0;
let _cod_tipopago = '';
let _fecha_factura = '';
let _pagado = '';
let _estatus = '--';
let _numrecla = '';
let _facturado = '';
let _gasto_eleg = '';
let _deducible = '';
let _co_pago = '';
let _coaseguro = '';
let _monto = '';
let _gastos_no_cub = '';
let _no_cheque = '';
let _transaccion = '';
let _cod_entrada = '';
let _cod_asignacion = '';
let _cod_icd = '';
let _tipotran = '';
let _pago_prov = '';
let _gasto_eleg = '';
let _wf_pagado = '';
let _no_requis = '';
let _nombre_asegurado = '';
let _nombre_reclamante = '';
let _fecha_siniestro = '';
let _no_poliza = '';
let _no_unidad = '';
let _no_tranrec = '';
let _ajust_interno = '';
let _mensaje = '';
let _no_factura = '';
	
	foreach -- CUANDO SOLO EL BLOQUE ESTA CREADO, QUE NO EXISTE EN RECRCMAE
		SELECT 
			b.nombre, 
			cod_entrada, 
			no_unidad, 
			cod_asignacion,
			(select nombre from cliclien where cod_cliente = a.cod_reclamante) as reclamante
		INTO
			_nombre_asegurado,
			_cod_entrada,
			_no_unidad,
			_cod_asignacion,
			_nombre_reclamante
		FROM atcdocde a
		INNER JOIN cliclien b ON a.cod_asegurado = b.cod_cliente
		AND no_documento = a_no_documento
		AND cod_asegurado = a_cod_reclamante
		AND cod_tipopago = '003'
		AND date(a.date_added) > _fecha --TO_DATE('2022/05/13', '%Y/%m/%d')

	 select count(*)
	   into _count_codasignacion
	   from rectrmae
	  where cod_asignacion = _cod_asignacion;

		if _count_codasignacion = 0 then
			let _estatus = 'En tramite';
			
			return 
			  _fecha_factura,
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
			  _nombre_asegurado,
			  _nombre_reclamante,
			  _fecha_siniestro,
			  _no_poliza,
			  _no_unidad,
			  _mensaje,
			  _no_factura
			  with resume;
		end if
	end foreach 
	
	
end if
end procedure