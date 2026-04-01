-- Insertando los valores de las cartas de Salud en emicartasal

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_pro497;

create procedure sp_pro497(
    a_no_documento	char(20),
    a_nom_cliente	varchar(100),
    a_fecha_aniv	date,
    a_dir			char(100),
    a_tel_pag1		char(10),
    a_tel_pag2		char(10),
    a_nom_agente	varchar(50), 
    a_usuario		char(8) default null,
    a_periodo		char(7),
    a_dir1			varchar(50),
    a_dir2			varchar(50),
    a_email			varchar(50))

returning smallint,
		  char(25);

define _cod_asegurado		char(10);
define _no_poliza			char(10);
define _cod_formapag		char(3);
define _cod_subramo			char(3);
define _cod_perpago			char(3);
define _cod_producto_new	char(5);
define _cod_producto		char(5);
define _cod_grupo			char(5);
define _prima_asegurado		dec(16,2);
define _error				smallint;
define _fecha_periodo		date;

--set debug file to "sp_pro172.trc";

set isolation to dirty read;

let _fecha_periodo = mdy(a_periodo[6,7], 1, a_periodo[1,4]);

--select emi_fecha_salud
--  into _fecha_periodo
--  from parparam;

--let _fecha_periodo = _fecha_periodo + 1 units day;

if a_fecha_aniv < _fecha_periodo then
	let a_fecha_aniv = a_fecha_aniv + 1 units year;
end if 

begin
on exception set _error    		
	if _error = -268 or _error = -239 then 
	   let _cod_producto_new =  sp_pro30g(_no_poliza, _cod_producto, a_periodo); --> verificando si en algun momento no se cambiaron los productos a algunas polizas

       if _cod_producto_new <> _cod_producto then
 		update emicartasal
 		   set periodo      = a_periodo,
 		       fecha_aniv   = a_fecha_aniv 	     
 		 where no_documento = a_no_documento;
       end if
	else
 		return _error, "Error al Actualizar";         
	end if
end exception 
 
call sp_sis21(a_no_documento) returning _no_poliza;
  
select cod_subramo,
	   cod_perpago,
	   cod_formapag,
	   cod_grupo
  into _cod_subramo,
	   _cod_perpago,
	   _cod_formapag,
	   _cod_grupo
  from emipomae
 where no_poliza = _no_poliza;

foreach
	select cod_producto,
		   prima_asegurado,
		   cod_asegurado 
	  into _cod_producto,
		   _prima_asegurado,
		   _cod_asegurado
	  from emipouni
	 where no_poliza = _no_poliza
	exit foreach;
end foreach

  set lock mode to wait;

insert into emicartasal(
		no_documento,
		nombre_cliente,
		fecha_aniv,
		direccion,
		telefono1,
		telefono2,
		celular,
		nombre_agente,
		user_added,
		date_added,
		por_edad,
		cod_subramo,
		cod_producto,
		prima,
		cod_perpago,
		cod_formapag,
		periodo,
		cod_grupo
		)
values	(
		a_no_documento,
		a_nom_cliente,
		a_fecha_aniv,  
		a_dir,           
		a_tel_pag1,    
		a_tel_pag2,    
		null,     
		a_nom_agente,
		a_usuario,
		current,
		0,
		_cod_subramo,
		_cod_producto,
		_prima_asegurado,
		_cod_perpago, 
		_cod_formapag,
		a_periodo,
		_cod_grupo
		);

update cliclien
   set direccion_1	= trim(a_dir1),
	   direccion_2	= trim(a_dir2),
	   e_mail		= trim(a_email)
 where cod_cliente	= _cod_asegurado;

end
return 0, "Actualizacion Exitosa";
end procedure;