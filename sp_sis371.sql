-- Procedimiento Para Actualizar los Datos de la tabla de cliclien desde cotizacion
-- 
-- Creado    : 25/03/2003 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis371;

create procedure "informix".sp_sis371(a_cotizacion int, a_cliente char(10) default null, a_accion integer)
returning integer,
          char(10);

define _razonsocial     char(100);
define _direccion       char(50);
define _primerapellido  char(40);
define _primernombre    char(40);
define _pasaporte		char(30);  
define _cedula			char(30);  
define _llave			char(30);
define _ruc				char(30);  
define _apartado		char(20);
define _cod_cliente     char(10);
define _telefono1		char(10);
define _telefono2		char(10);
define _email           char(30);
define _tipopersona     char(1);
define _error     	    smallint; 
define _cant            smallint;
define _existe          smallint;

define _provincia			char(2);
define _inicial				char(2);
define _sexo				char(1);
define _null				char(1);
define _asiento				char(7);										   									   
define _tomo				char(7);
define _razon_social		varchar(100);


--set debug file to "sp_sis371.trc";  
--trace on;                                                                 

set isolation to dirty read;

let _cod_cliente = null;
let _cant = 0;


let _provincia     = '';	
let _inicial	   = '';
let _sexo		   = '';
let _null		   = '';
let _asiento	   = '';
let _tomo		   = '';
let _razon_social  = '';

begin

on exception set _error 
 	return _error,
 	_cod_cliente;         
end exception           

if a_accion = 1 and (a_cliente is null or a_cliente = '') then
/**/
 select count(*)
   into _cant
   FROM insp_cot_pend
  where no_cotizacion = cast(a_cotizacion as varchar(10));
	if _cant = 1 then
		select cedula,
			   nombre_asegurado,
			   telefono1,
			   telefono2,
			   email,
			   direccion
		 into _cedula,
			  _primernombre,
			  _telefono1,
			  _telefono2,
			  _email,
			  _direccion
		 from insp_cot_pend
		where no_cotizacion = cast(a_cotizacion as varchar(10));

		update wf_db_autos
		   set cedula         = _cedula,
			   telefono1      = _telefono1,
			   telefono2      = _telefono2,
			   email          = _email,
			   direccion      = _direccion
		 where nrocotizacion = a_cotizacion;
			if _cedula is not null and trim(_cedula) <> '' then
				call sp_sis108(_cedula,1) returning _existe,_cod_cliente;
				if _existe = 0 then
					call sp_sis400(_cedula) returning _provincia,_inicial,_tomo,_asiento;																	   
					let _null = null;

					let _razon_social = trim(_primernombre); --|| trim(_cliente_ape) || trim(_cliente_ape_casada);
					call sp_sis175(_telefono1) returning _telefono1;
					call sp_sis175(_telefono2) returning _telefono2;
						--call sp_sis175(_celular) returning _celular;
					select sexo,
						   tipopersona		
					  into _sexo,
						   _tipopersona
					  from wf_db_autos
					 where nrocotizacion = a_cotizacion;

					call sp_sis372( _cod_cliente, --ls_valor_nuevo char(10),
						0,					--ll_nrocotizacion int,
						_tipopersona,		--ls_tipopersona char(1),
						'A',					--ls_tipocliente char(1),
						_primernombre,		--ls_primernombre char(40),
						'',					--ls_segundonombre char(40),
						'',					--ls_primerapellido char(40),
						'',					--ls_segundoapellido char(40),
						'',					--ls_apellidocasada char(40),
						_razon_social,  	--ls_razonsocial char(100),
						_cedula,        	--ls_cedula char(30),
						'',		   			--ls_ruc char(30),
						'',		   			--ls_pasaporte char(30),
						_direccion,		   	--ls_direccion char(50),
						_null,		   		--ls_apartado char(20), 
						_telefono1,		   	--ls_telefono1 char(10),
						_telefono2,		   	--ls_telefono2 char(10),
						_null,		   		--ls_fax char(10),
						_email ,         	--ls_email char(50),
						_null,            	--ld_fechaaniversario,
						_sexo,		   		--ls_sexo char(1),
						'informix',	   		--ls_usuario char(8),
						'001',		   		--ls_compania	char(3),
						'001',		   		--ls_agencia char(3),
						_provincia,	   		--ls_provincia char(2),
						_inicial,	   		--ls_inicial char(2),
						_tomo,		   		--ls_tomo char(7),
						'',			   		--ls_folio char(7),
						_asiento,	   		--ls_asiento char(7),
						'',			   		--ls_direccion2 varchar(50),
						_telefono2)	   		--ls_celular varchar(10),
						returning _error;
				end if
			end if
	end if
/**/
	foreach
		select cedula,
		       ruc,
		       pasaporte,
		       razonsocial,   
		       tipopersona,   
		       primernombre,  
		       primerapellido,
		       direccion,     
		       apartado,		
		       telefono1		
		  into _cedula,
		  	   _ruc,
		  	   _pasaporte,
			   _razonsocial,
			   _tipopersona,   
		  	   _primernombre,  
		  	   _primerapellido,
		  	   _direccion,     
		  	   _apartado,		
		       _telefono1		
		  from wf_db_autos
		 where nrocotizacion = a_cotizacion

	     if _tipopersona = 'N' then
			if _cedula is not null and _cedula <> '' then
			   let _llave = trim(_cedula);
			else
			   let _llave = trim(_pasaporte);
			end if
		 else
		 	let _llave = trim(_ruc);
	     end if 


		 foreach
			 select cod_cliente
			   into _cod_cliente
			   from cliclien
			  where cedula = _llave
			  order by cod_cliente
			  exit foreach;
		 end foreach

	     if _cod_cliente is null then
			return 1,
			_cod_cliente;
		 end if

		 if _telefono1 is not null or _telefono1 <> '' then
		   let _telefono1 = trim(_telefono1);
	       let _telefono1 = _telefono1[1,3]||"-"||_telefono1[4,7];
	     end if
/*
		if _cant = 1 then
		    update cliclien
		       set direccion_1     = _direccion,
			       apartado        = _apartado,
			       telefono1       = _telefono1,
				   e_mail          = _email,
				   telefono2       = _telefono2
		     where cod_cliente     = _cod_cliente;
		end if
*/
	 --           aseg_primer_nom = _primernombre,
	 --		    aseg_primer_ape = _primerapellido
 end foreach

else

{ FOREACH
	SELECT direccion,     
	       apartado,		
	       telefono1		
	  INTO _direccion,     
	  	   _apartado,		
	       _telefono1		
	  FROM wf_db_autos
	 WHERE nrocotizacion = a_cotizacion

	 IF _telefono1 IS NOT NULL OR _telefono1 <> '' THEN
	   LET _telefono1 = trim(_telefono1);
       LET _telefono1 = _telefono1[1,3]||"-"||_telefono1[4,7];
     END IF

	 UPDATE cliclien
	    SET direccion_1     = _direccion,
		    apartado        = _apartado,
		    telefono1       = _telefono1
	  WHERE cod_cliente     = a_cliente;}

	 let _cod_cliente = a_cliente;
-- end foreach

end if
return 0,
       _cod_cliente;
end

end procedure;
