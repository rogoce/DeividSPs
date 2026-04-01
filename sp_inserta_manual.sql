drop procedure sp_inserta_manual;
create procedure sp_inserta_manual()
returning integer;

define _no_poliza char(10);
define _cnt       smallint;

begin

foreach
	select no_poliza
	  into _no_poliza
	  from emirepo
	 where estatus = 2
	   and no_documento[1,2] in('02','23')
	   and user_added = 'MJARAMIL'

	select count(*)
	  into _cnt
	  from emirepol
	 where no_poliza = _no_poliza;

    if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt = 0 then

		INSERT INTO emirepol(
		no_poliza,
		user_added,
		cod_no_renov,
		no_documento,
		renovar,
		no_renovar,
		fecha_selec,
		vigencia_inic,
		vigencia_final,
		saldo,
		cant_reclamos,
		no_factura,
		incurrido,
		pagos,
		porc_depreciacion,
		cod_agente,
		estatus
		)
		SELECT
		no_poliza,
		user_added,
		cod_no_renov,
		no_documento,
		renovar,
		no_renovar,
		fecha_selec,
		vigencia_inic,
		vigencia_final,
		saldo,
		cant_reclamos,
		no_factura,
		incurrido,
		pagos,
		porc_depreciacion,
		cod_agente,
		4
		FROM emirepo
		WHERE no_poliza = _no_poliza;
		
		delete from emideren
		 where no_poliza = _no_poliza;
		 
		delete from emirepo
		 where no_poliza = _no_poliza;
	 
	end if	
end foreach
end 
return 0;

end procedure;
