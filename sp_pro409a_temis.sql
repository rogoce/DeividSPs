-- Procedimiento que genera el endoso de traspaso de cartera
-- Creado: 08/05/2017 - Autor: Román Gordón
-- Modificado:   23/08/2019  - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.
-- Copia del sp_pro409a para procesar Endosos de Temis:   13/06/2025  - Autor: Federico Coronado
-- execute procedure sp_pro409a()

drop procedure sp_pro409a_temis;
create procedure sp_pro409a_temis(a_usuario char(8), a_no_documento char(20))
returning	integer,
			varchar(200);

define _descripcion						varchar(200);
define _error_desc						varchar(50);
define _no_documento    				char(20);
define _no_poliza						char(10);
define _cod_impuesto					char(3);
define _periodo							char(7);
define _cod_agente_old					char(5);
define _porc_partic_cod_agente_old		decimal(16,2);
define _cod_agente_new					char(5);
define _porc_partic_cod_agente_new		decimal(16,2);
define _cod_agente_old2                 char(5);
define _porc_partic_cod_agente_old2		decimal(16,2);
define _cod_agente_new2                 char(5);
define _porc_partic_cod_agente_new2		decimal(16,2);
define _cod_agente_old3	                char(5);
define _porc_partic_cod_agente_old3		decimal(16,2);
define _cod_agente_new3                 char(5);
define _porc_partic_cod_agente_new3		decimal(16,2);
define _no_endoso						char(5);
define _cod_tipocalc					char(3);
define _cod_endomov						char(3);
define _cod_tipocan						char(3);
define _factor_impuesto					dec(16,2);
define _prima_suscrita					dec(16,2);
define _prima_retenida					dec(16,2);
define _suma_asegurada					dec(16,2);
define _suma_impuesto					dec(16,2);
define _prima_bruta						dec(16,2);
define _prima_neta						dec(16,2);
define _descuento						dec(16,2);
define _impuesto						dec(16,2);
define _recargo							dec(16,2);
define _prima							dec(16,2);
define _estatus_poliza					smallint;
define _cnt_ren							smallint;
define _cnt_agt							smallint;
define _cnt_agt_25      				smallint;  --AMORENO cod_agente: 02569
define _error_isam						integer;
define _error							integer;
define _fecha_efectiva					date;

--set debug file to "sp_pro409a_temis.trc";
--trace on;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

set isolation to dirty read;


foreach with hold
	select no_documento,
		   cod_agente_old,
		   porc_partic_cod_agente_old,
		   cod_agente_new,
		   porc_partic_cod_agente_new,
		   cod_agente_old2,
		   porc_partic_cod_agente_old2,
		   cod_agente_new2,
		   porc_partic_cod_agente_new2,
		   cod_agente_old3,
		   porc_partic_cod_agente_old3,
		   cod_agente_new3,
		   porc_partic_cod_agente_new3,
		   fecha_efectiva
	  into _no_documento,
		   _cod_agente_old,
		   _porc_partic_cod_agente_old,
		   _cod_agente_new,
		   _porc_partic_cod_agente_new,
		   _cod_agente_old2,
		   _porc_partic_cod_agente_old2,
		   _cod_agente_new2,
		   _porc_partic_cod_agente_new2,
		   _cod_agente_old3,
		   _porc_partic_cod_agente_old3,
		   _cod_agente_new3,
		   _porc_partic_cod_agente_new3,
		   _fecha_efectiva
	  from deivid_tmp:traspasos_corredor
	 where procesado = 0
	   and no_documento = a_no_documento
	 order by 2,1

	{if _cod_agente_old = _cod_agente_new then
		continue foreach;
	end if}

	begin work;
	let _no_poliza = sp_sis21(_no_documento);


	select count(*)
	  into _cnt_ren
	  from emireaut
	 where no_poliza = _no_poliza;

	if _cnt_ren is null then
		let _cnt_ren = 0;
	end if

	if _cnt_ren > 0 then
		return 1, 'Se esta Renovando: ' || trim(_no_documento) with resume;
		commit work;
		continue foreach;
	end if

	select estatus_poliza
	  into _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza <> 1 then
		update deivid_tmp:traspasos_corredor
		   set procesado = 2
		 where no_documento = _no_documento;

		return 1, 'No esta vigente: ' || trim(_no_documento) with resume;
		commit work;
		continue foreach;
	end if

	--- Verificamos si tiene mas de un corredor cod_agente1
	let _cnt_agt = 0;
	select count(*)
	  into _cnt_agt
	  from emipoagt
	 where no_poliza = _no_poliza
	   and cod_agente in (_cod_agente_old,_cod_agente_old2,_cod_agente_old3);

	if _cnt_agt is null then
		let _cnt_agt = 0;
	end if

	if _cnt_agt = 0 then
		update deivid_tmp:traspasos_corredor
		   set procesado = 2
		 where no_documento = _no_documento;

		return 1, 'Agente Anterior No pertenece al antiguo corredor: ' || trim(_no_documento) with resume;
		commit work;
		continue foreach;
	end if

/*
	if _cod_agente_old2 is not null and trim(_cod_agente_old2) <> '' then

		if _cod_agente_new2 IS NULL OR _cod_agente_new2 = '' then
		 	update deivid_tmp:traspasos_corredor
			   set procesado = 2
			 where no_documento = _no_documento;

			return 1, 'Agente nuevo 2 en blanco: ' || trim(_no_documento) with resume;
			commit work;
			continue foreach;
		 end if

		--- Verificamos si tiene mas de un corredor cod_agente2
		let _cnt_agt = 0;
		select count(*)
		  into _cnt_agt
		  from emipoagt
		 where no_poliza = _no_poliza
		   and cod_agente in (_cod_agente_old2);

		if _cnt_agt is null then
			let _cnt_agt = 0;
		end if

		if _cnt_agt = 0 then
			update deivid_tmp:traspasos_corredor
			   set procesado = 2
			 where no_documento = _no_documento;

			return 1, 'Agente Anterior 2 No pertenece al antiguo corredor: ' || trim(_no_documento) with resume;
			commit work;
			continue foreach;
		end if
	end if

	if _cod_agente_old3 is not null and trim(_cod_agente_old3) <> '' then

		if _cod_agente_new3 IS NULL OR _cod_agente_new3 = '' then
		 	update deivid_tmp:traspasos_corredor
			   set procesado = 2
			 where no_documento = _no_documento;

			return 1, 'Agente nuevo 3 en blanco: ' || trim(_no_documento) with resume;
			commit work;
			continue foreach;
		 end if

		--- Verificamos si tiene mas de un corredor cod_agente3
		let _cnt_agt = 0;
		select count(*)
		  into _cnt_agt
		  from emipoagt
		 where no_poliza = _no_poliza
		   and cod_agente in (_cod_agente_old3);

		if _cnt_agt is null then
			let _cnt_agt = 0;
		end if

		if _cnt_agt = 0 then
			update deivid_tmp:traspasos_corredor
			   set procesado = 2
			 where no_documento = _no_documento;

			return 1, 'Agente Anterior 3 No pertenece al antiguo corredor: ' || trim(_no_documento) with resume;
			commit work;
			continue foreach;
		end if
	end if
*/
	--- se adiciona por solicitud de corredor 02569 si tiene 25.5 no ejecutar endoso AMORENO: 23/08/2019
	{let _cnt_agt_25 = 0;
	select count(*)
	  into _cnt_agt_25
	  from emipoagt
	 where no_poliza = _no_poliza
	   and cod_agente = _cod_agente_new
	   and porc_comis_agt = 25.5 ;

	if _cnt_agt_25 is null then
		let _cnt_agt_25 = 0;
	end if

	if _cnt_agt_25 > 0 and trim(_cod_agente_old) = trim(_cod_agente_new) and trim(_cod_agente_new) = '02569' then  -- 23/08/2019,  AMORENO
		return 1, 'Procesado: 25.5% - ' || trim(_no_documento) with resume;
		continue foreach;
	else}
		call sp_pro409_temis(_no_poliza,a_usuario,'001',_cod_agente_old, _porc_partic_cod_agente_old, _cod_agente_new, _porc_partic_cod_agente_new, _cod_agente_old2, _porc_partic_cod_agente_old2, _cod_agente_new2, _porc_partic_cod_agente_new2, _cod_agente_old3, _porc_partic_cod_agente_old3, _cod_agente_new3, _porc_partic_cod_agente_new3, _fecha_efectiva) returning _error,_error_desc,_no_endoso;
	--end if

	if _error <> 0 then
		rollback work;
		let _error_desc = 'Póliza: ' || trim(_no_documento) || '. '|| _error_desc;
		return _error,_error_desc with resume;
		continue foreach;
	end if

	update deivid_tmp:traspasos_corredor
	   set procesado = 1
	 where no_documento = _no_documento;

	return 0, 'Procesado: ' || trim(_no_documento) with resume;

	commit work;
end foreach
return 0, "Actualizacion Exitosa";
end
end procedure;