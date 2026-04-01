-- Despliega los usuario Activo de cobros tipo supervisor y jefe
-- Creado     : 05/05/2011 - Autor: Henry Giron
--DROP PROCEDURE sp_sis391;
create procedure "informix".sp_sis391()
returning char(8),   -- 1. Usuario 						  usuario     	
	      char(200); -- 2. Nombre completo del usuario	  nombre		

DEFINE _usuario       char(8);   -- 1
DEFINE _correo		  char(100); -- 2
DEFINE _nombre		  char(200); -- 2
DEFINE _sucursal	  char(200); -- 2
DEFINE _cod_agencia	  char(3);

let    _correo   = "";
let    _nombre   = "";
let    _sucursal   = "";
let    _cod_agencia   = "";

SET ISOLATION TO DIRTY READ;
-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
	select distinct b.usuario ,
		   trim(b.e_mail),
		   b.descripcion ,
		   c.descripcion ,
		   b.codigo_agencia 
	 into _usuario,
	      _correo,
		  _nombre,
		  _sucursal,
		  _cod_agencia
	 from cobcobra a, 
	      segv05:insuser b, 
	      segv05:insagen c
	where a.usuario = b.usuario
	 	  and b.e_mail is not null
		  and b.status = 'A'
--		  and b.codigo_agencia = '010'
		  and b.codigo_compania = c.codigo_compania
		  and b.codigo_agencia = c.codigo_agencia
		  and a.activo = 1  and a.tipo_cobrador in (8,9) and a.usuario is not null
	order by b.codigo_agencia, b.usuario	
	  				 
		 return _usuario,    -- 1. Usuario 
				_nombre;     -- 2. Nombre completo del usuario
		   with resume;
		   
end foreach;

end procedure;
