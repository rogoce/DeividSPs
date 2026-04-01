-- Encabezado de los Estados de Cuenta para la descripcion de Los ramos de automovil,soda,incendio y multiriesgo
-- Creado por :    Roman Gordon	05/01/2011
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_co26;

create procedure "informix".sp_co26(a_no_documento     char(20))
returning	char(5),
			char(50),	--_descripcion
			char(10),	--_placa,		
			char(50),	--_color,
			char(30),	--_no_motor
			smallint;	--_ramo_sis			
		 
define _descripcion		char(100);
define _nombre_tipoauto	char(50);
define _nombre_modelo	char(50);
define _nombre_marca	char(50);
define _nombre_ramo		char(50);
define _color			char(50);
define _no_motor		char(30);
define _no_poliza		char(10);
define _placa			char(10);
define _cod_modelo		char(5);
define _no_unidad		char(5);
define _cod_marca		char(5);
define _cod_tipoauto	char(3);
define _cod_color		char(3);
define _cod_ramo		char(3);
define _cant_unidad		smallint;
define _ramo_sis		smallint;
define _ano_auto		smallint;

set isolation to dirty read;

foreach
	select cod_ramo,
		   no_poliza
	  into _cod_ramo,
		   _no_poliza
	  from emipomae
	 where no_documento = a_no_documento       --where no_poliza = _no_poliza
	 order by  vigencia_final desc
	exit foreach;
end foreach

-- Ramo y Subramo
select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;	

if _ramo_sis = '1' then
	select count(*)
	  into _cant_unidad
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cant_unidad > 10 then
		return	'',
				'Póliza con más de 10 unidades ',
				'',		
				'',
				'',
				2;
	else
		foreach
			select no_unidad
			  into _no_unidad
			  from emipouni
			 where no_poliza = _no_poliza  

			select no_motor
			  into _no_motor
			  from emiauto
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

			select cod_marca,
				   cod_modelo,
				   placa,
				   cod_color,
				   ano_auto
			  into _cod_marca,
				   _cod_modelo,
				   _placa,
				   _cod_color,
				   _ano_auto
			  from emivehic									 
			 where no_motor = _no_motor;					 

			select nombre										 
			  into _nombre_marca								 
			  from emimarca										 
			 where cod_marca = _cod_marca;						 

			select nombre,
				   cod_tipoauto
			  into _nombre_modelo,
				   _cod_tipoauto
			  from emimodel
			 where cod_modelo = _cod_modelo;

			select nombre
			  into _nombre_tipoauto
			  from emitiaut
			 where cod_tipoauto = _cod_tipoauto;

			select nombre
			  into _color
			  from emicolor
			 where cod_color = _cod_color;

			let _descripcion = trim(_nombre_marca) || " " || trim(_nombre_modelo) || " - " || _nombre_tipoauto || " - " ||_ano_auto;
			if _cant_unidad = 1 then
				return
					_no_unidad,
					_descripcion,
					_placa,		
					_color,
					_no_motor,
					_ramo_sis		
					with resume;
			else
				return	_no_unidad,
						_descripcion,
						_placa,		
						_color,
						'',
						_ramo_sis with resume;
			end if	 
		end foreach
	end if
elif _ramo_sis = '2' or _ramo_sis = '8' then
	foreach
		select no_unidad,
			   desc_unidad
		  into _no_unidad,
			   _descripcion
		  from emipouni
		 where no_poliza = _no_poliza
		 
		return	_no_unidad,
				_descripcion,
				'',		
				'',
				'',
				_ramo_sis		
				with resume;
		exit foreach;
	end foreach;
end if
end procedure;
