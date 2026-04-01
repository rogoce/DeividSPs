-- Procedure que se utiliza para crear clientes

drop procedure sp_sis81;

create procedure sp_sis81()
returning integer;

define _error	integer;

begin
on exception set _error
	return _error;
end exception

select *
  from cliclien
 where cod_cliente = "09813"
  into temp tmp_cliente;

update tmp_cliente
set cod_compania		= "001",
	cod_sucursal		= "001",
	cod_origen			= "001",
	cod_grupo			= "00001",
	cod_clasehosp		= "001",
	cod_espmedica		= "001",
	cod_ocupacion		= "038",
	cod_trabajo			= "029",
	cod_actividad		= "001",
	code_pais			= "001",
	code_provincia		= "01",
	code_ciudad			= "01",
	code_distrito		= "01",
	code_correg			= "01",
	nombre				= "",
	nombre_razon		= "",
	direccion_1			= null,
	direccion_2			= null,
	apartado			= null,
	tipo_persona		= "N",
	actual_potencial	= "A",
	cedula				= "",
	telefono1			= null,
	telefono2			= null,
	e_mail				= null,
	fax					= null,
	date_added			= today,
	user_added			= "",
	de_la_red			= 0,
	mala_referencia		= 0,
	desc_mala_ref		= NULL,
	fecha_aniversario	= "",
	sexo				= "M",
	digito_ver			= null,
	date_changed		= today,
	user_changed		= "",
	nombre_original		= "",
	ced_provincia		= null,
	ced_inicial			= null,
	ced_tomo			= null,
	ced_folio			= null,
	ced_asiento			= null,
	aseg_primer_nom		= "",
	aseg_segundo_nom	= null,
	aseg_primer_ape		= "",
	aseg_segundo_ape	= null,
	aseg_casada_ape		= null,
	ced_correcta		= 1,
	pasaporte			= 0,
	cotizacion			= null,
	de_cotizacion		= 0,
	celular				= null,
	dia_cobros1			= 1,
	dia_cobros2			= 1,
	contacto			= "",
	telefono3			= null,
	direccion_cob		= null,
	es_taller			= 0,
	proveedor_autorizado = null,
	ip_number			= null,
	periodo_pago        = 0,
	tipo_cuenta         = null,
	cod_cuenta          = null,
	cod_banco           = null,
	tipo_pago           = 2,
	cod_ruta            = null;

end

return 0;

end procedure