-- Modificando el reaseguro de las polizas con contrato allied, solamente debe ser para este contrato

-- Creado    : 25/04/2011 - Autor: Amado Perez M. 

drop procedure apm_meleyka2;

create procedure "informix".apm_meleyka2(a_no_remesa char(10))
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


set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _remesa_new = sp_sis13('001', 'COB', '02', 'par_no_remesa');

select * from cobremae				 --> Reversando la remesa
where no_remesa = a_no_remesa
into temp prueba;

update prueba
   set no_remesa = _remesa_new,
       fecha     = today,
	   actualizado = 0,
	   date_posteo = today,
	   subir_bo    = 0,
	   monto_chequeo = monto_chequeo * (-1);

insert into cobremae
select * from prueba;

drop table prueba;

select * from cobredet
where no_remesa = a_no_remesa
into temp prueba;

update prueba
   set no_remesa = _remesa_new,
       monto = monto * (-1),
	   fecha = today,
	   sac_asientos = 0,
	   subir_bo = 0;

insert into cobredet
select * from prueba;

drop table prueba;

end
return 0, "Actualizacion Exitosa " || _remesa_new ; 
end procedure