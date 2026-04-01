-- Modificando el reaseguro de las polizas con contrato allied, solamente debe ser para este contrato

-- Creado    : 25/04/2011 - Autor: Amado Perez M. 

drop procedure apm_meleyka;

create procedure "informix".apm_meleyka(a_no_remesa char(10))
returning integer, char(50);

define _no_cambio      smallint;
define _no_reclamo     char(10);
define _error          integer;
define _error_isam     integer;
define _error_desc     char(50);
define _no_cambio2     smallint;
define _orden          smallint;
define _cod_ramo       char(3);
define _cod_cober_reas char(3);
define _cod_contrato   char(5);
define _cedula         char(30);
define _monto          dec(16,2);
define _nombre         varchar(100);
define _cod_agente     char(10);
define _cuenta         varchar(30);


set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


select max(renglon)
  into _orden
  from cobredet
 where no_remesa = a_no_remesa;

--let _orden = 23;

foreach with hold
	select cedula, credito, cuenta
	  into _cedula, _monto, _cuenta
	  from tmpagt

	let _cod_agente = "";

    foreach
		select cod_agente, nombre
		  into _cod_agente, _nombre
		  from agtagent
		 where cedula = _cedula
		   and cod_cuenta = _cuenta
		order by 1
		exit foreach;
	end foreach


    let _orden = _orden + 1;

insert into cobredet (
		no_remesa,
		renglon,
		cod_compania,
		cod_sucursal,
		no_poliza,
		no_unidad,
		no_tranrec,
		cod_recibi_de,
		no_reclamo,
		cod_cobertura,
		no_recibo,
		doc_remesa,
		tipo_mov,
		monto,
		prima_neta,
		impuesto,
		monto_descontado,
		comis_desc,
		desc_remesa,
		saldo,
		periodo,
		fecha,
		actualizado,
		cod_agente,
		cod_auxiliar,
		sac_asientos,
		subir_bo,
		flag_web_corr,
		no_recibo2)
values (a_no_remesa,
		_orden,
		'001',
		'001',
		null,
		null,
		null,
		null,
		null,
		null,
        'cont',
		_cedula,
		'C',
		_monto * (-1),
		0,
		0,
		0,
		0,
		_nombre,
		0,
		'2011-07',
		'06/07/2011',
		0,
		_cod_agente,
		null,
		0,
		0,
		0,
		null
		);

end foreach
end
return 0, "Actualizacion Exitosa"; 
end procedure