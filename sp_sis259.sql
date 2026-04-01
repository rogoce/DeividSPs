--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis258() 

drop procedure sp_sis259;

create procedure sp_sis259()
returning	integer			as error_,
			integer			as error_isam,
			varchar(100)	as descripcion;

define 	_posible_recobro		smallint;   
define 	_asis_legal				smallint;
define 	_tiene_audiencia		smallint;
define	_fecha_audiencia		date;
define	_cod_lugci				char(3);
define	_parte_policivo			char(10);
define	_hora_audiencia			datetime hour to fraction(5);
define	_no_resolucion			varchar(20);
define	_estatus_audiencia		smallint;
define  _CodMigracionSiniestro	char(10);
        
define _error                   integer;      
define _error_isam              integer;  
define _error_desc              varchar(100);    

--set debug file to "sp_sis245.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	
	return	_error,
			_error_isam,
			_CodMigracionSiniestro;
end exception

foreach with hold
	select CodMigracionSiniestro
	  into _CodMigracionSiniestro
	  from Tbl_SiniestrosBitacora
	 where CodMigracionSiniestro is not null

	select posible_recobro,
		   asis_legal,
		   tiene_audiencia,
		   fecha_audiencia,
		   cod_lugci,
		   parte_policivo,
		   hora_audiencia,
		   no_resolucion,
		   estatus_audiencia
	  into _posible_recobro,
		   _asis_legal,
		   _tiene_audiencia,
		   _fecha_audiencia,
		   _cod_lugci,
		   _parte_policivo,
		   _hora_audiencia,
		   _no_resolucion,
		   _estatus_audiencia
	  from recrcmae
	 where no_reclamo = _CodMigracionSiniestro;
	 
	update Tbl_SiniestrosBitacora set
           IdAplicaAsistenciaLegal = _asis_legal,
		   IdEstatusJuicio = _estatus_audiencia,
		   NroResolucion = _no_resolucion,
		   IdLugarAudiencia = _cod_lugci,
		   FechaJuicio = _fecha_audiencia,
		   HoraJuicio = _hora_audiencia,
		   NroCarpetilla = _parte_policivo,
		   Salvamento = (case when _posible_recobro = 1 then true else false end)
	 where CodMigracionSiniestro = _CodMigracionSiniestro;
		   
end foreach




return 0,0,'Actualización Exitosa';
end


end procedure;