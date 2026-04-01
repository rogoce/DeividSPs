-- Modificando el reaseguro de las polizas con contrato allied, solamente debe ser para este contrato

-- Creado    : 25/04/2011 - Autor: Amado Perez M. 

drop procedure apm_meleyka3;

create procedure "informix".apm_meleyka3(a_no_remesa char(10))
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
define _remesa_new	   char(10);
define _cant           smallint;


--SET DEBUG FILE TO "meleyka3.trc";
--TRACE ON ;


set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _cedula;
end exception

let _remesa_new = sp_sis13('001', 'COB', '02', 'par_no_remesa');


select * from cobremae		  --> Insertando la nueva remesa		 
where no_remesa = a_no_remesa
into temp prueba;

update prueba
   set no_remesa = _remesa_new,
       fecha     = today,
	   actualizado = 0,
	   date_posteo = today,
	   user_added  = user_posteo,
	   subir_bo    = 0,
	   monto_chequeo = monto_chequeo;

insert into cobremae
select * from prueba;

drop table prueba; --}

let _orden = 0;

select max(renglon)			--> Insertando la nueva remesa
  into _orden
  from cobredet
 where no_remesa = _remesa_new;

if _orden is null then
	let _orden = 0;
end if

foreach 
	select cedula, credito, cuenta, cod_agente
	  into _cedula, _monto, _cuenta, _cod_agente
	  from tmpagt
	 where paso <> 1

--	let _cod_agente = "";
--	let _cant = 0;

{    select count(*)
	  into _cant
	  from agtagent
	 where cedula = _cedula
	   and cod_cuenta = _cuenta;
--	   and ced_correcta = 1;

    if _cant > 1 then
	 update tmpagt
	    set paso = 2
	  where cedula = _cedula;
	  continue foreach;
	end if
 --}
    select nombre
	  into _nombre
	  from agtagent
	 where cod_agente = _cod_agente;

   if _cod_agente = "" or _cod_agente is null then
    	continue foreach;
   end if

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
values (_remesa_new,
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
		'2014-07',
		'10/07/2011',
		0,
		_cod_agente,
		null,
		0,
		0,
		0,
		null
		); --}

 update tmpagt
    set paso = 1
  where cod_agente = _cod_agente;

end foreach 
end
return 0, "Actualizacion Exitosa " || _remesa_new ; 
end procedure