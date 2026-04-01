-- Obtener el estado de los reclamos el modulo web de consulta corredores para reclamos

-- Creado: 19/05/2013 - Autor: Enocjahaziel Carrasco

-- SIS - Pagina Web consulta de el estado de los reclamos modulo de los corredores consultas web.

drop procedure sp_web23a;

create procedure "informix".sp_web23a( a_cod_agente varchar(10),a_bloque varchar(10),a_num_recla varchar(20) )
returning integer;

define _caso 			integer;
define _total 			integer;
define _tipotran 		varchar(10);
define _cod_tipopago 	char(3);
define _no_tranrec 		varchar(10);
define _estatus			varchar(20);
define _cnt_cob			integer;
define _cnt_true        integer;


set isolation to dirty read;
--SET DEBUG FILE TO "sp_web23.trc"; 
--TRACE ON;

 if a_bloque <> '' and a_num_recla = ''  then
		let _caso = 1;       
 else 
	if a_bloque  = '' and a_num_recla <> ''  then
		let _caso = 2;
	else 
		let _caso = 3;
	end if 	
 end if
 
 let _total = 0;
 
-- busqueda por bloque
	if _caso = 1 then
		foreach
				 SELECT rectrmae.cod_tipopago,
						cod_tipotran,
						no_tranrec
				   into _cod_tipopago,
						_tipotran,
						_no_tranrec						
				   FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
			 inner join emipoagt on recrcmae.no_poliza = emipoagt.no_poliza
			 inner join emipomae on recrcmae.no_poliza = emipomae.no_poliza
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
			   order by fecha_factura DESC

			if _tipotran = '013' then
				let _estatus = "Declinado";
			else 
				 let _estatus = "Ninguno";
			end if 
			
			let _cnt_cob = 0;
			let _cnt_true = 0;
			foreach
				 select	no_tranrec
				   into	_no_tranrec
				   from rectrcob
				  where no_tranrec = _no_tranrec

				if _cod_tipopago = '003' or _estatus = "Declinado" then
					let _cnt_true = _cnt_true + 1;
				end if
			end foreach
			
			if _cnt_true > 0 then
				let _total = _total + _cnt_true;
			end if
		end foreach 
		return _total;		
	end if
	
	if _caso = 2 then
		foreach
				 SELECT rectrmae.cod_tipopago,
						cod_tipotran,
						no_tranrec
				   into _cod_tipopago,
						_tipotran,
						_no_tranrec	
				   FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
			 inner join emipoagt on recrcmae.no_poliza = emipoagt.no_poliza
			 inner join emipomae on recrcmae.no_poliza = emipomae.no_poliza
	         inner join atcdocde  on recrcmae.no_documento = atcdocde.no_documento and   atcdocde.cod_asignacion = recrcmae.cod_asignacion
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
             order by fecha_factura DESC

			if _tipotran = '013' then
				let _estatus = "Declinado";
			else 
				 let _estatus = "Ninguno";
			end if 
			
			let _cnt_cob = 0;
			let _cnt_true = 0;
			foreach
				 select	no_tranrec
				   into	_no_tranrec
				   from rectrcob
				  where no_tranrec = _no_tranrec

				if _cod_tipopago = '003' or _estatus = "Declinado" then
					let _cnt_true = _cnt_true + 1;
				end if
			end foreach
			
			if _cnt_true > 0 then
				let _total = _total + _cnt_true;
			end if
		end foreach 
		return _total;		
	end if
  if _caso = 3 then
		foreach
				 SELECT rectrmae.cod_tipopago,
						cod_tipotran,
						no_tranrec
				   into _cod_tipopago,
						_tipotran,
						_no_tranrec	
             FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
			 inner join emipoagt on recrcmae.no_poliza = emipoagt.no_poliza
			 inner join emipomae on recrcmae.no_poliza = emipomae.no_poliza
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
             order by fecha_factura DESC
			 
			if _tipotran = '013' then
				let _estatus = "Declinado";
			else 
				 let _estatus = "Ninguno";
			end if 
			
			let _cnt_cob = 0;
			let _cnt_true = 0;
			foreach
				 select	no_tranrec
				   into	_no_tranrec
				   from rectrcob
				  where no_tranrec = _no_tranrec

				if _cod_tipopago = '003' or _estatus = "Declinado" then
					let _cnt_true = _cnt_true + 1;
				end if
			end foreach
			
			if _cnt_true > 0 then
				let _total = _total + _cnt_true;
			end if
		end foreach 
		return _total;		
	end if
	end procedure