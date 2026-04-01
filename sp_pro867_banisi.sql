-- Ingreso a parmailsend para ser enviado por correo
-- CARTA DE POLIZA NUEVA Y RENOVACION
-- ANGEL TELLO 04/12/2013
--se excluye coas min  Armando, 14/04/2015
--execute procedure sp_pro867('','N')


drop procedure sp_pro867_banisi;
create procedure sp_pro867_banisi()
returning	smallint,
			char(30);


define r_descripcion		char(100);
define _no_poliza		char(10);
define _corredor		char(5);
define _nueva_renov	char(1);
define _cod_ramo		char(3);
define _cod_contratante char(10);
define _no_documento    char(20);
define v_tipo_envio		char(10);
define r_error_isam		smallint;
define _carta_bienv		smallint;
define r_error			smallint;
define _fronting	    smallint;
define _tipo_notif		smallint;
define _adj_file        smallint;
define _adjunto         smallint;
define _flag         smallint;
define _cnt             smallint;	
define _secuencia2		integer;
define _secuencia		integer;
define _cod_grupo		char(5);

define _cod_agente      char(5);
define _mail_cliente    varchar(200);
define _mail_agente     varchar(200);

begin

on exception set r_error, r_error_isam, r_descripcion
 	return r_error, r_descripcion;
end exception

set isolation to dirty read;

--set debug file to "sp_pro867.trc";
--trace on;

foreach
	select distinct emi.no_poliza
	  into _no_poliza
	  from emipomae emi
	inner join emipoacr acr on acr.no_poliza = emi.no_poliza
	where vigencia_inic between '01/10/2023' and '30/11/2023'
   and emi.cod_grupo in ('1122','77850','77870','77857','77960')
   and emi.nueva_renov = 'R'
{	select no_poliza,nueva_renov
	  into _no_poliza,_nueva_renov
	  from emipomae
	 where cod_grupo in ('1122','77850','77870','77857','1078','77960')  -- SD#3010 77960  11/04/2022 10:00
  	  and cod_ramo = '002'
	  and actualizado = 1
	  and nueva_renov = 'R'
	  and month(vigencia_inic) in (10,11)
	  and year(vigencia_inic) = 2021
	  and estatus_poliza = 1
}	  
	call sp_pro867(_no_poliza,'R') returning r_error, r_descripcion;
end foreach
return 0,'actualizacion exitosa';
end
end procedure;