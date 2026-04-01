
create procedure "informix".sp_cob29(a_no_remesa char(10), a_usuario char(8))
returning integer,
		  char(150);

define _desc_renglon		varchar(100);
define _mensaje				char(100);
define _error_desc			char(50);
define _no_comp				char(10);
define _user_posteo			char(8);
define _periodo_par			char(7);
define _periodo				char(7);
define _cod_chequera		char(3);
define _cod_compania		char(3);
define _cod_coasegur		char(3);
define _cod_sucursal		char(3);
define _cod_banco			char(3);
define _tipo_remesa			char(1); 
define _porc_comis_agt_e	dec(5,2);
define _porc_comis_agt		dec(5,2);
define _monto_arreglo		dec(16,2);
define _monto_banco			dec(16,2);
define _saldo_recup			dec(16,2);
define _mto_rec				dec(16,2);
define _cantidad			smallint;
define _cnt_paex			smallint;
define _cnt_ofac			smallint;
define _actualizado			smallint;
define _cnt_excep_canc		smallint;
define _error_2				integer;
define _error				integer;
define _cnt					integer;
define _fecha_ul_com		date;
define _fecha_param			date;
define _date_posteo			date;
define _fec_hoy				date;
define _fecha				date;
define _Tipo_B              smallint;

{if a_no_remesa = '1374577' then
	SET DEBUG FILE TO "sp_cob29.trc";
	trace on;
end if}

set isolation to dirty read;

begin
on exception set _error, _error_2, _error_desc 
 	return _error, _error_desc;
end exception           

select tipo_remesa,
       cod_compania,
	   cod_sucursal,
	   actualizado,
	   date_posteo,
	   user_posteo,
	   periodo,
	   cod_banco,
	   monto_chequeo,
	   fecha,
	   cod_chequera
  into _tipo_remesa,
       _cod_compania,
	   _cod_sucursal,
	   _actualizado,
	   _date_posteo,
	   _user_posteo,
	   _periodo,
	   _cod_banco,
	   _monto_banco,
	   _fecha,
	   _cod_chequera
  from cobremae
 where no_remesa = a_no_remesa;

let _fec_hoy = current;

if _actualizado = 1 then
	let _mensaje = "Remesa #: " || a_no_remesa || " Fue Actualizada el Dia " || _date_posteo || " Por " || _user_posteo;
	return 1, _mensaje; 
end if

select par_ase_lider,
	   cob_periodo,
	   rec_fecha_prov,
	   agt_fecha_comis	
  into _cod_coasegur,
	   _periodo_par,
	   _fecha_param,
	   _fecha_ul_com	
  from parparam
 where cod_compania = _cod_compania;

-- Postear en un Periodo Cerrado
if _tipo_remesa <> "F" then -- Remesas de Cierre de Caja

	if _periodo < _periodo_par then
		return 1, "No Puede Actualizar una Remesa para un Periodo Cerrado ...";
	end if

	-- Postear en un periodo de comisiones cerrado
	if _fecha <= _fecha_ul_com then
		return 1, "No Puede Actualizar para una Fecha de Comisiones ya Cerrada";
	end if

end if

delete from cobredet
 where no_remesa = a_no_remesa
   and renglon   = 0;

-- Actualizacion del Numero de Comprobante Automatico
if _tipo_remesa in ('C', 'F', 'T') then
	if _cod_banco <> "146" then
		let _cod_banco    = "146";
		let _cod_chequera = "023";

		update cobremae
		   set cod_banco    = _cod_banco,
		       cod_chequera = _cod_chequera,
			   hora_impresion = current
		 where no_remesa    = a_no_remesa;
	else	--Se implemento 21/05/2018 3:38 pm
		update cobremae
		   set hora_impresion = current
		 where no_remesa    = a_no_remesa;
	end if
	
	{
	if _cod_chequera = "023" then

		let _no_comp = sp_sis13("001", 'COB', '02', 'cob_no_comp');

		update cobredet
		   set no_recibo = "CD" || trim(_no_comp)
		 where no_remesa = a_no_remesa;

	end if
	}
end if
--{
if _tipo_remesa = 'A' then	--Recibo Automatico

	begin
		define _no_recibo    char(10);
		define _no_remesa    char(10);
		define _encontrado   smallint;
		define _diferencia   integer;
		define _contador     smallint;
		define _renglon      smallint;
		define _recibo1      integer;
		define _recibo2      integer;

		-- Verificacion para el Numero de Recibo Duplicado
		foreach
			select no_recibo
			  into _no_recibo
			  from cobredet
			 where no_remesa = a_no_remesa
			   and renglon  <> 0 
			 group by no_recibo
			 order by no_recibo 

			let _encontrado = 0;

			foreach
				select no_remesa, 	renglon 
				  into _no_remesa,	_renglon
				  from cobredet
				 where no_recibo   = _no_recibo
				   and actualizado = 1 
				   and tipo_mov    = 'E'
				   and no_remesa   <> a_no_remesa
				 order by no_remesa, renglon

				let _encontrado = 1;
				exit foreach;
			end foreach
			-- [HENRY] Buscar Encontrado
			foreach
				select no_remesa, renglon 
				  into _no_remesa, _renglon
				  from cobredet
				 where no_recibo   = _no_recibo
				   and actualizado = 1 
				   and tipo_mov    = 'B'
				   and no_remesa   <> a_no_remesa
				 order by no_remesa, renglon

				let _encontrado = 1;
				let _mensaje = "El Recibo #: " || _no_recibo || " Ya Fue Anulado en la Remesa #: " || _no_remesa ||
				               " Renglon #: " || _renglon;
				return 1, _mensaje;
			end foreach
			
			if _encontrado = 0 then
				foreach
					select no_remesa, 	renglon 
					  into _no_remesa,	_renglon
					  from cobredet
					 where no_recibo   = _no_recibo
					   and actualizado = 0 
					   and tipo_mov    matches '*' 
					   and no_remesa   <> a_no_remesa
					 order by no_remesa, renglon

					let _encontrado = 1;
					exit foreach;
				end foreach

				if _encontrado = 1 then
				
				   let _Tipo_B = 0;  -- [HENRY] Si remesa actualizada contine moviento tipo B de anulación.
				   
				select count(*) 
				  into _Tipo_B
				  from cobredet
				 where no_recibo   = _no_recibo
				   and actualizado = 0
				   and tipo_mov = 'B'
				   and no_remesa = a_no_remesa;				 
				
					if _Tipo_B = 0 then
						let _mensaje = "El Recibo #: " || _no_recibo || " Fue Capturado en la Remesa #: " || _no_remesa ||
									" Renglon #: " || _renglon;
						return 1, _mensaje;
					end if
					
				end if
			end if			
		end foreach
	end
end if
--}
if _tipo_remesa = 'M' then	--Recibo Manual

	begin

		define _no_recibo    char(10);
		define _no_remesa    char(10);
		define _encontrado   smallint;
		define _contador     smallint;
		define _renglon      smallint;
		define _diferencia   integer;
		define _recibo1      integer;
		define _recibo2      integer;

		-- Verificacion para el Numero de Recibo Duplicado
		--{
		foreach
			select no_recibo
			  into _no_recibo
			  from cobredet
			 where no_remesa = a_no_remesa
			   and renglon  <> 0 
			 group by no_recibo 
			 order by no_recibo 

			let _encontrado = 0;

			foreach
				select no_remesa, 	renglon 
				  into _no_remesa,	_renglon
				  from cobredet
				 where no_recibo   = _no_recibo
				   and actualizado = 1 
				   and tipo_mov    = 'E' 
				   and no_remesa   <> a_no_remesa
				 order by no_remesa, renglon

				let _encontrado = 1;
				exit foreach;
			end foreach
			--[HENRY]Ver tipo_remesa=M
			foreach
				select no_remesa, 	renglon 
				  into _no_remesa,	_renglon
				  from cobredet
				 where no_recibo   = _no_recibo
				   and actualizado = 1 
				   and tipo_mov    = 'B'
				   and no_remesa   <> a_no_remesa
				 order by no_remesa, renglon

				let _encontrado = 1;
				let _mensaje = "El Recibo #: " || _no_recibo || " Ya Fue Anulado en la Remesa #: " || _no_remesa ||
				               " Renglon #: " || _renglon;
				return 1, _mensaje;
			end foreach

			if _encontrado = 0 then
				foreach
					select no_remesa, 	renglon 
					  into _no_remesa,	_renglon
					  from cobredet
					 where no_recibo   = _no_recibo
					   and actualizado = 0 
					   and tipo_mov    matches '*' 
					   and no_remesa   <> a_no_remesa
					 order by no_remesa, renglon

					let _encontrado = 1;
					exit foreach;
				end foreach

				if _encontrado = 1 then
					let _mensaje = "El Recibo #: " || _no_recibo || " Fue Capturado en la Remesa #: " || _no_remesa ||
					               " Renglon #: " || _renglon;
					return 1, _mensaje;
				end if
			end if			
		end foreach
		--}
		-- Verificacion para la Secuencia de Recibos
		let _contador = 0;

		foreach
			select no_recibo
			  into _no_recibo
			  from cobredet
			 where no_remesa = a_no_remesa
			   and renglon  <> 0 
			 group by no_recibo 
			 order by no_recibo 

			let _contador = _contador + 1;

			if _contador = 1 then
				let _recibo1 = _no_recibo;
			end if				

			let _recibo2 = _no_recibo;

			if _recibo1 <> _recibo2 then
				let _diferencia = _recibo2 - _recibo1;
				if _diferencia <> 1 then

					let _mensaje = "El Recibo #: " || _recibo1 + 1 ||
						               " No ha sido Capturado ...";
					return 1, _mensaje;
				end if
				let _recibo1 = _no_recibo;
			end if
		end foreach
	end
end if

-- Verificacion de Aplicacion de Reclamos
begin
	define _no_tranrec char(10);
	define _renglon    smallint;
	define _pagado     integer;
			  
	foreach	
		select renglon,
			   no_tranrec	
		  into _renglon,
			   _no_tranrec
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  = 'T'

		select pagado
		  into _pagado
		  from rectrmae
		 where no_tranrec = _no_tranrec;

		if _pagado = 1 then
			let _mensaje = "La Transaccion de Reclamos del Renglon #: " || _renglon ||
			               " Ya Fue Aplicada";
			return 1, _mensaje;
		end if
	end foreach
end 

-- Verificacion de Primas en Suspenso

begin

	define _doc_remesa		char(30);
	define _no_recibo_otro	char(10);
	define _no_rem_otr		char(10);
	define _no_recibo		char(10);
	define _monto_rem		dec(16,2);
	define _monto_sus		dec(16,2);
	define _fecha_sus		date;
	define _act_cobsuspe	smallint;

	foreach	
		select doc_remesa, 
			   sum(monto)
		  into _doc_remesa,
			   _monto_rem
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  = 'A'
		 group by doc_remesa

		select monto
		  into _monto_sus
		  from cobsuspe
		 where doc_suspenso = _doc_remesa
		   and cod_compania = _cod_compania;

		if _monto_sus is null then
			let _mensaje = "No Existe Prima en Suspenso para Documento #: " || _doc_remesa;
			return 1, _mensaje;
		end if

		let _monto_rem = _monto_rem * -1;

		if _monto_rem > _monto_sus then
			let _mensaje = "Monto a Aplicar es Mayor que lo Pendiente de Aplicar, Documento # " || _doc_remesa;
			return 1, _mensaje;
		end if
	end foreach

	foreach	
		select doc_remesa, 
			   no_recibo
		  into _doc_remesa,
			   _no_recibo
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  = 'A'

		foreach	
			select no_recibo,
				   no_remesa,
				   fecha
			  into _no_recibo_otro,
				   _no_rem_otr,
				   _fecha_sus
			  from cobredet
			 where doc_remesa = _doc_remesa
			   and tipo_mov   = 'E'
			 order by fecha	desc

			if _no_recibo <> _no_recibo_otro then
				let _mensaje = "Recibo del Documento # " || trim(_doc_remesa) || " No Coincide, Verifique Remesa # " || _no_rem_otr;
				return 1, _mensaje;
			end if

			select actualizado
			  into _act_cobsuspe
			  from cobsuspe
			 where doc_suspenso = _doc_remesa;	

			if _act_cobsuspe = 0 then
				let _mensaje = "La Remesa que creo el Documento # " || trim(_doc_remesa) || " No esta Actualizada, Verifique Remesa # " || _no_rem_otr;
				return 1, _mensaje;
			end if

			exit foreach;
		end foreach
	end foreach
end


--Puesto en comentario hasta que se defina la pólitica de pago a pólizas canceladas/anuladas 26/03/2018
{
select count(*)
  into _cnt_excep_canc
  from tec_historico
 where no_remesa = a_no_remesa;

if _cnt_excep_canc is null then
	let _cnt_excep_canc = 0;
end if

if _cnt_excep_canc = 0 then

	if a_no_remesa not in ('1296017','1296299','1297272') then

		begin
			define _desc_renglon	varchar(150);
			define _renglon    		smallint;
			define _no_poliza  		char(10);
			
			let _desc_renglon = '';

			foreach
				select distinct renglon,
					   c.no_poliza
				  into _renglon,
					   _no_poliza
				  from cobredet c, emipomae e
				 where c.doc_remesa = e.no_documento
				   and c.no_remesa = a_no_remesa
				   and c.tipo_mov  in ('P')
				   and e.estatus_poliza in (2,4) --Cancelada o Anulada
				   and e.actualizado = 1

				call sp_cob329(_no_poliza) returning _error;

				if _error < 0 then
					return 1, 'Error en la Verificación de Pólizas Anuladas/Canceladas';
				elif _error = 0 then
					continue foreach;
				end if

				if _desc_renglon = '' then
					let _desc_renglon = _desc_renglon || cast(_renglon as varchar(4));
				else
					let _desc_renglon = _desc_renglon || ', ' || cast(_renglon as varchar(4));
				end if
			end foreach

			if _desc_renglon <> '' then
				let _mensaje = 'La(s) Póliza(s) en el/los renglon(es): ' || trim(_desc_renglon) || ' no puede(n) recibir pagos por estar Cancelada(s)/Anulada(s). Verifique...';
				return 1, _mensaje;
			end if
		end
	end if
end if
}
-- Verificacion para el Numero Interno de Polizas
begin
	define _no_poliza  		char(10);
	define _renglon    		smallint; 
	define _cod_agente 		char(5);
	define _encontrado 		smallint;
	define _tipo_mov 		char(1);
	define _no_documento	char(20);
	define _no_doc_pol		char(20);
	define _impuesto        dec(16,2);
	define _prima_n         dec(16,2);
	define _monto_desc		dec(16,2);
	define _monto_man		dec(16,2);
	define _monto_calc		dec(16,2);
	define _porc_partic		dec(16,2);

	foreach	
		select no_poliza,
		       renglon,
			   tipo_mov,
			   doc_remesa,
			   impuesto,
			   prima_neta,
			   monto_descontado
		  into _no_poliza,
		       _renglon,
			   _tipo_mov,
			   _no_documento,
			   _impuesto,
			   _prima_n,
			   _monto_desc
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  in ('P', 'N')

		--Control de Montos por Movimiento de prima (Pagos y Notas de Crédito)
		if _tipo_mov = 'P' and _prima_n < 0 then
			let _mensaje = "El movimiento de Pago de Prima debe ser mayor a 0, Verifique...Renglon # " || _renglon;
			return 1, _mensaje;
		elif _tipo_mov = 'N' and _prima_n > 0 then
			let _mensaje = "El movimiento de Nota de Crédito debe ser menor a 0, Verifique...Renglon # " || _renglon;
			return 1, _mensaje;
		end if

		select no_documento
		  into _no_doc_pol
		  from emipomae
		 where no_poliza = _no_poliza;

		if trim(_no_documento) <> trim(_no_doc_pol) then
			let _mensaje = "El Numero de Poliza digitado difiere del numero de Poliza de Emision, Verifique...";
			return 1, _mensaje;
		end if

		if _no_documento = "0503-00026-01" then
			let _mensaje = "El Numero de Poliza 0503-00026-01 esta bloqueado para recibir movimientos";
			return 1, _mensaje;
		end if

		if _no_documento in ('0114-00344-01','0514-00004-01','0614-00049-01') then
			let _mensaje = 'La(s) Póliza(s) no puede recibir pagos por estar Cancelada(s)/Anulada(s). Verifique...';
			return 1, _mensaje;
		end if

		if _no_poliza is null then
			let _mensaje = "El Numero Interno de Poliza del Renglon #: " || _renglon || " Esta Errado.  Por Favor Verifique ";
			return 1, _mensaje;
		end if

		let _cnt_ofac = 0;

		select count(*)
		  into _cnt_ofac
		  from ofac
		 where no_documento = _no_doc_pol;

		if _cnt_ofac is null then
			let _cnt_ofac = 0;
		end if
		
		if _cnt_ofac <> 0 then
			let _mensaje = "La Póliza  " || _no_doc_pol || " esta bloqueado para recibir movimientos, lista OFAC.  Por Favor Verifique ";
			return 1, _mensaje;
		end if

		let _encontrado = 0;

	    foreach	
			select cod_agente
			  into _cod_agente
			  from cobreagt
			 where no_remesa   = a_no_remesa
			   and renglon     = _renglon
			let _encontrado = 1;
			exit foreach;
		end foreach

		if _encontrado = 0 then
			let _mensaje = "No se creo el registro del Renglon #: " || _renglon ||
			               " Para el Corredor(cobreagt).  Por Favor Verifique ";
			return 1, _mensaje;
		end if

		select sum(monto_man),
			   sum(porc_partic_agt),
			   sum(monto_calc)
		  into _monto_man,
			   _porc_partic,
			   _monto_calc
		  from cobreagt
		 where no_remesa = a_no_remesa
		   and renglon   = _renglon;

		if _monto_desc <> 0.00 then		
			if _monto_desc <> _monto_man then
				let _mensaje = "La Comision Descontada Esta Errada en el Renglon #: " || _renglon;
				return 1, _mensaje;
			else
				if _monto_calc = 0 then
					let _mensaje = "La Comision Descontada Esta Errada en el Renglon #: " || _renglon;
					return 1, _mensaje;
				end if
			end if
		end if

		if _porc_partic <> 100 then
			let _mensaje = "El % de Participacion No Suma 100 en el Renglon #: " || _renglon;
			return 1, _mensaje;
		end if

		if abs(_impuesto) > abs(_prima_n) then
			let _mensaje = "El Impuesto no debe ser mayor a la prima neta, Renglon #: " || _renglon ||
			               " Verificar Configuracion Regional de la Pc. ";
			return 1, _mensaje;
		end if

		foreach
			select cod_agente,
				   porc_comis_agt
			  into _cod_agente,
				   _porc_comis_agt
			  from cobreagt
			 where no_remesa = a_no_remesa
			   and renglon = _renglon

			select porc_comis_agt
			  into _porc_comis_agt_e
			  from emipoagt
			 where no_poliza = _no_poliza
			   and cod_agente = _cod_agente;

			if _porc_comis_agt <> _porc_comis_agt_e then
				update cobreagt
				   set porc_comis_agt = _porc_comis_agt_e
				 where no_remesa	= a_no_remesa
				   and renglon		= _renglon
				   and cod_agente	= _cod_agente;
			end if
		end foreach

		-- Para cuando son las aplicaciones de creditos que son procesos masivos poner esto en comentario
		if _user_posteo <> "GERENCIA" then
			foreach
				select cod_agente
				  into _cod_agente
				  from cobreagt
				 where no_remesa = a_no_remesa
				   and renglon   = _renglon

				select count(*)
				  into _cantidad
				  from emipoagt
				 where no_poliza  = _no_poliza
				   and cod_agente = _cod_agente;

				if _cantidad = 0 then					
					select count(*)
					  into _cantidad
					  from endedmae
					 where no_poliza     = _no_poliza
					   and cod_endomov   = "012"
					   and actualizado   = 1
					   and fecha_emision >= _fecha;

					if _cantidad = 0 then
						let _mensaje = "Corredor No Esta en la Poliza, Renglon #: " || _renglon ||
						               " .Por Favor Verifique ";
						return 1, _mensaje;		
					end if
				end if	
			end foreach		
		end if--}
	end foreach
end	

-- Verificacion para el Numero Interno de Transaccion de Reclamos
begin

	define _no_tranrec char(10);
	define _renglon    smallint; 

	foreach	
		select no_tranrec,
			   renglon
		  into _no_tranrec,
			   _renglon
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  in ('T')

		if _no_tranrec is null then
			let _mensaje = "El Numero Interno de Transaccion del Renglon #: " || _renglon ||
			               " Esta Errado.  Por Favor Verifique ";
			return 1, _mensaje;
		end if
	end foreach
end	

-- Verificacion para el Numero Interno de Reclamos
begin

	define _cod_cliente char(10);
	define _no_reclamo  char(10);
	define _cod_cober   char(5);
	define _renglon     smallint; 

	foreach	
		select no_reclamo,
			   cod_cobertura,
			   renglon,
			   cod_recibi_de
		  into _no_reclamo,
			   _cod_cober,
			   _renglon,
			   _cod_cliente
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  in ('S','R','D')

		if _no_reclamo is null or _cod_cober  is null then
			let _mensaje = "El Numero de Reclamos del Renglon #: " || _renglon ||
			               " Esta Errado.  Por Favor Verifique ";
			return 1, _mensaje;
		end if

		if _cod_cliente is null then
			let _mensaje = "Es Necesario Capturar de Quien se esta Recibiendo el Pago " ||
			               "Renglon #: " || _renglon || " Por Favor Verifique ";
			return 1, _mensaje;
		end if
	end foreach
end

-- Verificacion de Cuentas de Mayor con Auxliliares
begin
	call sp_cob324(a_no_remesa) returning _error, _mensaje;

    if _error = 1 then
		return _error, _mensaje;
	end if
end	

-- Actualizacion de Deuda de Agentes
call sp_cob191(a_no_remesa) returning _error, _mensaje;

if _error <> 0 then
	return _error, _mensaje;
end if

-- Verificacion de cobro legal -- Amado 22-05-2013
{call sp_cob333(a_no_remesa) returning _error, _mensaje; Puesto en Comentario 18/05/18

-- Actualizacion de Cobros Externos Legales -- Amado 11-01-2013
call sp_cob315(a_no_remesa) returning _error, _mensaje;

if _error <> 0 then
	return _error, _mensaje;
end if}

-- Devolucion de Primas por Poliza Cancelada
call sp_cob325(a_no_remesa) returning _error, _mensaje;

if _error <> 0 then
	return _error, _mensaje;
end if

-- Actualizacion de Creacion de Primas en Suspenso
begin
	define _doc_remesa char(30);
	define _monto      dec(16,2);
	define _desc_remesa char(50);
	
	LET _monto = 0.00;
	LET _desc_remesa = "";

	foreach	
		select doc_remesa
		  into _doc_remesa
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  = 'E'
		 group by doc_remesa
		 
		{select doc_remesa, --BANISI
			   desc_remesa,
		       sum(monto)
		  into _doc_remesa,
			   _desc_remesa,
		       _monto
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  = 'E'
		 group by doc_remesa, desc_remesa
}
		select count(*)
		  into _cnt
		  from cobsuspe
		 where doc_suspenso = _doc_remesa 
		   and cod_compania = _cod_compania;

		if _cnt = 0 then				--puesto en prod 21/08/2013 armando.
--*
{		 if a_no_remesa = '1419976' then --BANISI
		  
		 	   insert into cobsuspe(
				doc_suspenso,
				cod_compania,
				cod_sucursal,
				monto,
				fecha,
				coaseguro,
				asegurado,
				poliza,
				ramo,
				actualizado,
				user_added,
				date_added
				)
				values(
				_doc_remesa,
				_cod_compania,
				'001',
				_monto,
				'31/01/2019',
				"",
				_desc_remesa,
				_doc_remesa,
				NULL,
				0,
				'MCONCEPC',
				'31/01/2019'
				);
            else}
        	let _mensaje = "No se creo el suspenso: " || trim(_doc_remesa) || " Elimine el renglon y vuelva a crearlo.";
			return 1, _mensaje;
            --end if	
		end if

		update cobsuspe
		   set actualizado  = 1
		 where doc_suspenso = _doc_remesa 
		   and cod_compania = _cod_compania;
	end foreach

	{
	select count(*)
	  into _cnt_paex
	  from cobpaex0
	 where no_remesa_ancon = a_no_remesa;

	if _cnt_paex > 0 then
		call sp_cob307(a_no_remesa) returning _error,_mensaje;

		if _error <> 0 then
			return _error, _mensaje;
		end if
	end if
	}
end 

-- Actualizacion de Aplicacion de Primas en Suspenso
begin

	define _doc_remesa char(30);
	define _monto_rem  dec(16,2);
	define _monto_sus  dec(16,2);

    foreach	
		select doc_remesa, 
			   sum(monto)
		  into _doc_remesa,
			   _monto_rem
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  = 'A'
		 group by doc_remesa

		update cobsuspe
		   set monto        = monto + _monto_rem 
		 where doc_suspenso = _doc_remesa 
		   and cod_compania = _cod_compania;

		-- crear cobsuspe0 a partir de cobsuspe antes de que se elimine el registro. puesto en prod. 27/01/2015
        insert into cobsuspe0
        select * from cobsuspe
         where doc_suspenso = _doc_remesa 
		   and cod_compania = _cod_compania
		   and monto        = 0;		   
		   
		delete from cobsuspe
		 where doc_suspenso = _doc_remesa 
		   and cod_compania = _cod_compania
		   and monto        = 0;
	end foreach
end 

-- Actualizacion de Saldos de Polizas y del Ultimo Pago
begin
	define _no_documento  char(20);
	define _no_poliza  	  char(10);
	define _monto_desc    dec(16,2);
	define _monto	   	  dec(16,2); 
	define _cnt           smallint;

	let _cnt        = 0;
	let _monto_desc = 0;

	foreach	
		select no_poliza,
			   monto
		  into _no_poliza,
			   _monto
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  in ('P', 'N', 'X')

		update emipomae
		   set saldo     = saldo - _monto
		 where no_poliza = _no_poliza;
	end foreach

	foreach	
		select no_poliza,
			   monto,
			   doc_remesa
		  into _no_poliza,
			   _monto,
			   _no_documento
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  in ('P')

		--call sp_cob192(_no_documento, _fecha, _monto);  -- Polizas con Pronto Pago Se puso en comentario 07/03/2013

		update emipomae
		   set fecha_ult_pago = _fecha
		 where no_poliza = _no_poliza;
		
		--Este proceso se desactiva debido a que el descuento es lineal y el endoso se hace al emitir la poliza. Armando, 02/07/2015
		--{ se habilita nuevamente por las polizas que ya estaban sin descuento antes del cambio. 16/07/2015
	   	if _cod_chequera in("031","029","030") then --son chequeras de visa y ach para saber que es una remesa de este tipo
			select count(*)
			  into _cnt
			  from cobpronde
			 where no_poliza = _no_poliza
			   and procesado = 0;

			let _monto_desc = 0;
			if _cnt > 0 then
				foreach
					select monto_descuento
					  into _monto_desc
					  from cobpronde
					 where no_poliza = _no_poliza
					   and procesado = 0

					call sp_pro862b(_no_poliza, a_usuario, _monto_desc) returning _error, _mensaje; -- creacion del endoso de pronto pago

					if _error = 0 then
						update cobpronde
						   set procesado = 1
						 where no_poliza = _no_poliza;
					end if
				end foreach
			end if
		end if --}
	end foreach
end

-- Actualizacion de Aplicacion de Reclamos
begin
	define _no_tranrec char(10);
	define _renglon    smallint;

	foreach	
		select renglon,
			   no_tranrec	
		  into _renglon,
			   _no_tranrec
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  = 'T'

		update rectrmae
		   set pagado       = 1,
		       no_remesa    = a_no_remesa,
			   renglon      = _renglon,
			   fecha_pagado = _fecha
		 where no_tranrec   = _no_tranrec;
	end foreach
end 

-- Actualizacion de Recuperos, Deducibles y Salvamentos
begin
	define _valor_parametro2	char(20);
	define _valor_parametro		char(20);
	define _numrecla			char(18);
	define _no_tranrec_char		char(10);
	define _no_tran_char		char(10);
	define _cod_cliente			char(10);
	define _no_reclamo			char(10); 
	define _periodo_rec			char(7);
	define _rec_periodo			char(7);
	define _cod_cobertura		char(5);  
	define _cod_tipotran		char(3);
	define _cod_tipopago		char(3);
	define _version				char(2);
	define _tipo_mov			char(1);  
	define _salvamento			dec(16,2);
	define _deducible			dec(16,2);
	define _recupero			dec(16,2);
	define _monto				dec(16,2);
	define _renglon				smallint; 
	define _fecha_no_server		date;

	select rec_periodo
	  into _rec_periodo
	  from parparam;

	select version
      into _version
	  from insapli
	 where aplicacion = 'REC';

	select valor_parametro
      into _valor_parametro
	  from inspaag
	 where codigo_compania  = _cod_compania
	   and aplicacion       = 'REC'
	   and version          = _version
	   and codigo_parametro	= 'fecha_recl_default';

	if trim(_valor_parametro) = '1' then   --toma la fecha del servidor
		if month(current) < 10 then
			let _periodo_rec = year(current) || "-0" || month(current);
		else
			let _periodo_rec = year(current) || "-" || month(current);
		end if
	else								   --toma la fecha de un parametro establecido por computo.
		select valor_parametro			  
	      into _valor_parametro2
		  from inspaag
		 where codigo_compania  = _cod_compania
		   and aplicacion       = 'REC'
		   and version          = _version
		   and codigo_parametro	= 'fecha_recl_valor';

		   let _fecha_no_server = date(_valor_parametro2);				

		if month(_fecha_no_server) < 10 then
			let _periodo_rec = year(_fecha_no_server) || "-0" || month(_fecha_no_server);
		else
			let _periodo_rec = year(_fecha_no_server) || "-" || month(_fecha_no_server);
		end if
	end if

	foreach	
		select no_reclamo, 
			   cod_cobertura, 
			   tipo_mov, 
			   renglon, 
			   monto,
			   cod_recibi_de 
		  into _no_reclamo, 
			   _cod_cobertura, 
			   _tipo_mov, 
			   _renglon, 
			   _monto,
			   _cod_cliente
		  from cobredet
		 where no_remesa = a_no_remesa
		   and tipo_mov  in ('D', 'S', 'R')
       
		let _salvamento = 0;
		let _recupero   = 0;
		let _deducible  = 0;
		
		if _periodo_rec < _rec_periodo then
			let _mensaje = "No Puede Actualizar para un periodo de Reclamos ya Cerrado, Por favor Verifique.";
			return 1, _mensaje;
		end if

		if _tipo_mov = 'S' THEN   -- Salvamento

			select cod_tipotran
			  into _cod_tipotran
			  from rectitra
			 where tipo_transaccion = 5;    
			
			let _cod_tipopago = '004';
			let _salvamento   = _monto * -1;

		elif _tipo_mov = 'R' then	-- recupero

			select cod_tipotran
			  into _cod_tipotran
			  from rectitra
			 where tipo_transaccion = 6;    

			let _cod_tipopago = '004';
			let _recupero     = _monto * -1;
			
			select sum(rectrmae.monto) * -1
			  into _mto_rec
			  from rectrmae, rectitra  
			 where rectitra.cod_tipotran = rectrmae.cod_tipotran 
			   and rectrmae.no_reclamo = _no_reclamo 
			   and rectrmae.actualizado = 1
			   and rectitra.tipo_transaccion = 6;
			   
			select sum(monto_arreglo)
              into _monto_arreglo
              from recrecup
			 where no_reclamo = _no_reclamo;
			 
            let _saldo_recup = 0;
			let  _saldo_recup = abs(_monto_arreglo) - abs(_mto_rec + _monto);
			 
			if _saldo_recup <= 0 then
				update recrecup
				   set estatus_recobro = 7
				 where no_reclamo = _no_reclamo;
            end if			
		else -- deducible

			select cod_tipotran
			  into _cod_tipotran
			  from rectitra
			 where tipo_transaccion = 7;    

			let _cod_tipopago = '003';
			let _deducible    = _monto * -1;
		end if

		-- Asignacion del Numero Interno y Externo de Transacciones
		let _no_tran_char    = sp_sis12(_cod_compania, _cod_sucursal, _no_reclamo);
		let _no_tranrec_char = sp_sis13(_cod_compania, 'REC', '02', 'par_tran_genera');

		-- Lectura de la Tabla de Reclamos
	    select numrecla
		  into _numrecla
		  from recrcmae
		 where no_reclamo = _no_reclamo;

		-- Insercion de las Transacciones de Salvamentos, Recuperos, Deducibles
		let _monto = _monto * -1;

		if trim(_valor_parametro) = '1' THEN

			insert into rectrmae(
					no_tranrec,
					cod_compania,
					cod_sucursal,
					no_reclamo,
					cod_cliente,
					cod_tipotran,
					cod_tipopago,
					no_requis,
					no_remesa,
					renglon,
					numrecla,
					fecha,
					impreso,
					transaccion,
					perd_total,
					cerrar_rec,
					no_impresion,
					periodo,
					pagado,
					monto,
					variacion,
					generar_cheque,
					actualizado,
					user_added)
			values(	_no_tranrec_char,
					_cod_compania,
					_cod_sucursal,
					_no_reclamo,
					_cod_cliente,
					_cod_tipotran,
					_cod_tipopago,
					NULL,
					a_no_remesa,
					_renglon,
					_numrecla,
					CURRENT,
					0,
					_no_tran_char,
					0,
					0,
					0,
					_periodo_rec,
					1,
					_monto,
					0,
					0,
					1,
					a_usuario);
		else
			insert into rectrmae(
					no_tranrec,
					cod_compania,
					cod_sucursal,
					no_reclamo,
					cod_cliente,
					cod_tipotran,
					cod_tipopago,
					no_requis,
					no_remesa,
					renglon,
					numrecla,
					fecha,
					impreso,
					transaccion,
					perd_total,
					cerrar_rec,
					no_impresion,
					periodo,
					pagado,
					monto,
					variacion,
					generar_cheque,
					actualizado,
					user_added)
			values(	_no_tranrec_char,
					_cod_compania,
					_cod_sucursal,
					_no_reclamo,
					_cod_cliente,
					_cod_tipotran,
					_cod_tipopago,
					NULL,
					a_no_remesa,
					_renglon,
					_numrecla,
					_fecha_no_server,
					0,
					_no_tran_char,
					0,
					0,
					0,
					_periodo_rec,
					1,
					_monto,
					0,
					0,
					1,
					a_usuario);
		end if

		-- Insercion de las Coberturas (Transacciones)
		insert into rectrcob(
				no_tranrec,
				cod_cobertura,
				monto,
				variacion)
		values(	_no_tranrec_char,
				_cod_cobertura,
				_monto,
				0);

		-- Actualizacion de los Valores Acumulados de las Coberturas
		update recrccob
		   set salvamento       = salvamento       + _salvamento,
		       recupero         = recupero         + _recupero,
			   deducible_pagado = deducible_pagado + _deducible
		 where no_reclamo       = _no_reclamo
		   and cod_cobertura    = _cod_cobertura;

		-- Actualizacion en la Remesa del Numero de Transaccion Generado
		update cobredet
		   set no_tranrec = _no_tranrec_char
		 where no_remesa  = a_no_remesa
		   and renglon    = _renglon;

		-- Reaseguro a Nivel de Transaccion
		call sp_sis58(_no_tranrec_char) returning _error, _mensaje;

		if _error <> 0 then
			return _error, _mensaje;
		end if

		-- Reaseguro de Reclamos (Nueva Estructura de Asientos)
		call sp_rea008(3, _no_tranrec_char) returning _error, _mensaje;

		if _error <> 0 then
			return _error, _mensaje;
		end if
	end foreach
end

--Verifica si el corredor se desconto la comision (Proceso de Pago anticipado de comisiones)
call sp_cob313(a_no_remesa,a_usuario) returning _error,_mensaje;

if _error <> 0 then
	return _error,_mensaje;
end if

-- Reaseguro de Cobros (Nueva Estructura) implementada 07/08/2012
call sp_sis171(a_no_remesa) returning _error, _mensaje;

if _error <> 0 then
	return _error, _mensaje;
end if

-- Actualizacion de los Datos de la Remesa
update cobremae
   set user_posteo = a_usuario,
       date_posteo = current,
	   actualizado = 1
 where no_remesa   = a_no_remesa;

update cobredet
   set periodo      = _periodo,
       fecha        = _fecha,
	   actualizado  = 1,
	   sac_asientos = 0
 where no_remesa    = a_no_remesa;

update cobredet
   set saldo     = 0
 where no_remesa = a_no_remesa
   and tipo_mov  in ("A","E");

-- remesa de pagos externos
update cobpaex0
   set insertado_remesa = 1
 where no_remesa_ancon  = a_no_remesa;

-- Subir_BO para el DWH

call sp_sis95(a_no_remesa) returning _error, _mensaje;

if _error <> 0 then
	return _error, _mensaje;
end if

-- Creacion de las Cajas

--if _tipo_remesa in ('A', 'M', "J", "H") then

if _tipo_remesa in ('A', 'M') then

	let _cnt = 0;

   	select count(*)
	  into _cnt
      from cobcieca
     where fecha        <> _fec_hoy
       and cod_chequera = _cod_chequera
       and actualizado  = 0;

  	if _cnt > 1 then
  		LET _mensaje = "No Puede Actualizar la remesa, Tiene mas de una caja abierta, Por favor Verifique.";
  		RETURN 1, _mensaje;
  	end if
	
	call sp_cob229(_cod_chequera, _fecha, _tipo_remesa) returning _error, _mensaje;

	if _error <> 0 then
		return _error, _mensaje;
	end if

end if

-- Cheques de Devolucion de Primas en Suspenso
call sp_che119(a_no_remesa) returning _error, _mensaje;

if _error <> 0 then
	return _error, _mensaje;
end if

-- Refacturacion de Polizas de Salud con saldo a 61+ dias
call sp_pro350(a_no_remesa,a_usuario) returning _error, _mensaje;

if _error <> 0 then
	return _error, _mensaje;
end if

--Adelanto de Comision
call sp_che136(a_no_remesa) returning _error,_mensaje;

if _error <> 0 then
	return _error,_mensaje;
end if 

-- Movimientos de Pólizas General Representatives (Banco Delta)
call sp_cob326(a_no_remesa) returning _error,_mensaje;

if _error <> 0 then
	return _error,_mensaje;
end if 

-- Actualización de letras en Emiletra y Bitacora de Suspensión de Coberturas
call sp_cob343(a_no_remesa) returning _error,_mensaje;
if _error <> 0 then
	return _error,_mensaje;
end if 

if _error <> 0 then
	return _error,_mensaje;
end if

-- Actualización de campo nueva_renov en cobredet   26/05/2015
call sp_cob365(a_no_remesa) returning _error,_mensaje;

if _error <> 0 then
	return _error,_mensaje;
end if

-- Liberación automatica de excepcion de cobros. 21/01/2015
call sp_cob248b(a_no_remesa) returning _error,_mensaje;

if _error <> 0 then
	return _error,_mensaje;
end if

-- Actualización de las tablas historicas de los procesos electrónicos
call sp_cob363(a_no_remesa) returning _error,_mensaje;

if _error <> 0 then
	return _error,_mensaje;
end if 

-- Reaseguro de Cobros}
{
call sp_rea008(2, a_no_remesa) returning _error, _mensaje;

if _error <> 0 then
	return _error, _mensaje;
end if
}

--***** Liberacion Automatica de Asignaciones de Salud que Estan en Mora ***********
{
BEGIN
	DEFINE _no_poliza  		CHAR(10);
	DEFINE _monto	   		DEC(16,2); 
	DEFINE _no_documento	char(20);
	DEFINE _mes_char        CHAR(2);
	DEFINE _ano_char		CHAR(4);
	DEFINE _periodo_c       CHAR(7);
	DEFINE v_por_vencer     DEC(16,2);
	DEFINE v_exigible       DEC(16,2);
	DEFINE v_corriente		DEC(16,2);
	DEFINE v_monto_30		DEC(16,2);
	DEFINE v_monto_60		DEC(16,2);
	DEFINE v_monto_90		DEC(16,2);
	DEFINE v_apagar			DEC(16,2);
	DEFINE v_saldo			DEC(16,2);
	DEFINE _moro_total      DEC(16,2);
	DEFINE _estatus_poliza   smallint;
	DEFINE _carta_aviso_canc smallint;
	DEFINE _cod_ramo         char(3);
--	DEFINE _cod_asignacion   char(10);
	DEFINE _fecha_hoy        DATE;

	FOREACH	
	 SELECT no_poliza,
	        monto,
			doc_remesa
	   INTO _no_poliza,
	        _monto,
		   _no_documento
	   FROM cobredet
	  WHERE no_remesa = a_no_remesa
	    AND tipo_mov  IN ('P')

		select estatus_poliza,
		       cod_ramo,
			   carta_aviso_canc
		  into _estatus_poliza,
		       _cod_ramo,
			   _carta_aviso_canc
		  from emipomae
		 where actualizado = 1
		   and no_poliza   = _no_poliza;

		if _cod_ramo = "018" and _estatus_poliza = 1 then  --salud y vigente

			let _moro_total = 0;
			let _fecha_hoy  = today;

			IF  MONTH(_fecha_hoy) < 10 THEN
				LET _mes_char = '0'|| MONTH(_fecha_hoy);
			ELSE
				LET _mes_char = MONTH(_fecha_hoy);
			END IF

			LET _ano_char = YEAR(_fecha_hoy);
			LET _periodo_c  = _ano_char || "-" || _mes_char;

			CALL sp_cob33c("001","001",_no_documento,_periodo_c,_fecha_hoy)
			RETURNING v_por_vencer, v_exigible, v_corriente, v_monto_30, v_monto_60, v_monto_90, v_saldo;

			let _moro_total = v_monto_30 +  v_monto_60 +  v_monto_90;

            if _moro_total <= 0 and _carta_aviso_canc = 0 then
			   --	let _cod_asignacion = "";
--			   foreach--
--					SELECT cod_asignacion
--					  INTO _cod_asignacion
--					  FROM atcdocde
--					 WHERE completado         = 0
--				       AND suspenso          <> 1
--					   AND en_mora            = 1
--					   AND no_documento       = _no_documento--
--					exit foreach;
--				end foreach
--
--				if _cod_asignacion is not null and _cod_asignacion <> "" then
					update atcdocde
					   set en_mora         = 0,
						   user_mora       = a_usuario,
						   fec_libero_mora = _fecha_hoy
					 where no_documento    = _no_documento;
			   --	end if
			end if
		end if
	END FOREACH
END
}

let _mensaje = "Actualizacion Exitosa ...";
return 0, _mensaje;

end
end procedure 
                                                                                                                      
