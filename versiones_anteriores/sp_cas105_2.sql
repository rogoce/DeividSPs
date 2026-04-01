-- Procedimiento que Selecciona los Filtros de cada Campaña
-- Creado    : 23/09/2010- Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas105;

create procedure sp_cas105(
a_cod_campana	char(10),
a_codramo		char(255) default "*",
a_codmoros		char(255) default "*",
a_codformapag	char(255) default "*",
a_codzonacob	char(255) default "*",
a_codagente		char(12000) default "*",
a_codsuc		char(255) default "*",
a_codarea		char(255) default "*",
a_codstatus		char(255) default "*",
a_codcobra		char(255) default "*",
a_codgrupo		char(255) default "*",
a_codiacob		char(255) default "*",
a_codacre		char(255) default "*",
a_codpago		char(255) default "*",
a_codespecial	char(255) default "*",
a_codsubramo	char(255) default "*",
a_codgesti		char(1)	  default "*",
a_xperiodo		char(1)	  default "*",  
a_xtipo		    char(255) default "*",   
a_xvencer_cdc	char(1)	  default "*",  
a_xexigible_cdc char(1)	  default "*",
ax_anio  		char(4)	  default "*",
ax_mes 		    char(2)	  default "*"
)returning integer,
          char(100);

define _error	  	 	integer;
define _tipo	  	 	char(1);
define _codigo	  	 	char(50);
define _ramo_nom  	 	char(50);
define _nom_moros	 	char(50);
define _nom_formapag 	char(50);
define _nom_subramo		char(50);
define _nom_zonacob	 	char(50);
define _nom_suc		 	char(50);
define _nom_agente	 	char(50);
define _nom_area	 	char(50);
define _nom_status	 	char(50);
define _nom_grupo	 	char(50);
define _nom_pago	 	char(50);
define _nom_acre	 	char(50);
define _dia			 	char(10);
define _cod_ramo		char(3);
define _dif_especiales	char(1);
define _cod_campana		char(10);
define _n_cobrador		varchar(50);
define _estatus         smallint;
define li_tipo          smallint;
define ls_periodo	    char(7);


--begin
on exception set _error
   --	rollback work;
	return _error, "error al ingresar los filtros de campana";
end exception

--set debug file to "sp_cas105.trc";
--trace on;
let li_tipo = 0;
let ls_periodo = '';
let _codigo = "";
let _n_cobrador = null;
--proceso que ingresa los filtros por ramo en la tabla cascampanafil
if a_codramo <> "*" then
	let _tipo = sp_sis04(a_codramo);  -- separa los valores del string en una tabla de codigos
	if _tipo <> "E" then -- (I) Incluir los Registros
	   foreach
		   select codigo
		     into _codigo	
		     from tmp_codigos

		   select nombre
			 into _ramo_nom
			 from prdramo
		   	where cod_ramo = _codigo; 

		   insert into cascampanafil(
			   cod_campana,
			   cod_filtro,
			   tipo_filtro,
			   descripcion)
		   values(
			   a_cod_campana,
			   _codigo,
			   1,
			   _ramo_nom); 
	   end foreach;			
		  
		{else		        -- (e) excluir estos registros

		   update tmp_cob
		   	  set seleccionado = 0
			where seleccionado = 1
			  and cod_agente in (select codigo from tmp_codigos); }

		end if
		drop table tmp_codigos;
end if

let _codigo = "";
--proceso que ingresa los filtros por morosidad en la tabla cascampanafil
if a_codmoros <> "*" then
	let _tipo = sp_sis04(a_codmoros);  -- separa los valores del string en una tabla de codigos
	if _tipo <> "E" THEN -- (I) Incluir los Registros
	   foreach
		   select codigo
		     into _codigo	
		     from tmp_codigos

		   select descripcion
			 into _nom_moros
			 from insmoros
		   	where cod_moros = _codigo; 

		   insert into cascampanafil(
			   cod_campana,
			   cod_filtro,
			   tipo_filtro,
			   descripcion)
		   values(
			   a_cod_campana,
			   _codigo,
			   2,
			   _nom_moros); 
	   end foreach;			
	   
	end if
	drop table tmp_codigos;

end if


let _codigo = "";
--proceso que ingresa los filtros por forma de pago en la tabla cascampanafil
if a_codformapag <> "*" then
	let _tipo = sp_sis04(a_codformapag);  -- separa los valores del string en una tabla de codigos
	if _tipo <> "E" then -- (i) incluir los registros
	   foreach
	   	   select codigo
		     into _codigo	
		     from tmp_codigos

		   select nombre
		     into _nom_formapag
		     from cobforpa
			where cod_formapag = _codigo;

		   insert into cascampanafil(
		      cod_campana,
		      cod_filtro,
		      tipo_filtro,
		      descripcion)
		   values(
		      a_cod_campana,
		      _codigo,
		      3,
		      _nom_formapag); 
		end foreach;			
		  
		{else		        -- (e) excluir estos registros

		   update tmp_cob
		   	  set seleccionado = 0
			where seleccionado = 1
			  and cod_agente in (select codigo from tmp_codigos); }

		end if
		drop table tmp_codigos;
end if

let _codigo = "";
--proceso que ingresa los filtros por forma de pago en la tabla cascampanafil
if a_codzonacob <> "*" then
	let _tipo = sp_sis04(a_codzonacob);  -- separa los valores del string en una tabla de codigos
	if _tipo <> "E" then -- (i) incluir los registros
	   foreach
	   	   select codigo
		     into _codigo	
		     from tmp_codigos

		   select nombre
		     into _nom_zonacob
		     from cobcobra
			where cod_cobrador = _codigo;

		   insert into cascampanafil(
		      cod_campana,
		      cod_filtro,
		      tipo_filtro,
		      descripcion)
		   values(
		      a_cod_campana,
		      _codigo,
		      4,
		      _nom_zonacob); 
		end foreach;			

	end if
		drop table tmp_codigos;
end if




let _codigo = "";
--proceso que ingresa los filtros por agente en la tabla cascampanafil
if a_codagente <> "*" then
	let _tipo = sp_sis04b(a_codagente);  -- separa los valores del string en una tabla de codigos
	if _tipo <> "E" then -- (i) incluir los registros
	   foreach
		   select codigo
		     into _codigo	
		     from tmp_codigos

		   select nombre
		     into _nom_agente
			 from agtagent
			where cod_agente = _codigo;

		   insert into cascampanafil(
			  cod_campana,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   values(
			  a_cod_campana,
			  _codigo,
			  5,
			  _nom_agente);  
	   end foreach;			
	  
	{else		        -- (e) excluir estos registros

	   update tmp_cob
	   	  set seleccionado = 0
		where seleccionado = 1
		  and cod_agente in (select codigo from tmp_codigos); }

	end if
	drop table tmp_codigos;
end if


let _codigo = "";
--proceso que ingresa los filtros por sucursal en la tabla cascampanafil
if a_codsuc <> "*" then
	let _tipo = sp_sis04(a_codsuc);  -- separa los valores del string en una tabla de codigos
   	if _tipo <> "E" then -- (i) incluir los registros
   	   foreach
	   	   select codigo
		     into _codigo	
		     from tmp_codigos

		   select descripcion
			 into _nom_suc
			 from insagen
			where codigo_agencia = _codigo;

	   	   insert into cascampanafil(
			  cod_campana,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   values(
			  a_cod_campana,
			  _codigo,
			  6,
			  _nom_suc); 
   	   end foreach;			
	   end if
	   drop table tmp_codigos;
end if


let _codigo = "";
--proceso que ingresa los filtros por area de cobros en la tabla cascampanafil
if a_codarea <> "*" then
	let _tipo = sp_sis04(a_codarea);  -- separa los valores del string en una tabla de codigos
   	if _tipo <> "E" then -- (i) incluir los registros
   	   foreach
	   	   select codigo
		     into _codigo	
		     from tmp_codigos

		   select nombre
			 into _nom_area
			 from gencorr
			where code_correg = _codigo;

	   	   insert into cascampanafil(
			  cod_campana,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   values(
			  a_cod_campana,
			  _codigo,
			  7,
			  _nom_area); 
   	   end foreach;			
		  
		{else		        -- (e) excluir estos registros

		   update tmp_cob
		   	  set seleccionado = 0
			where seleccionado = 1
			  and cod_agente in (select codigo from tmp_codigos); }
	   end if
	   drop table tmp_codigos;
end if

let _codigo = "";
--proceso que ingresa los filtros por estaus de la poliza en la tabla cascampanafil
if a_codstatus <> "*" THEN
	LET _tipo = sp_sis04(a_codstatus);  -- Separa los Valores del String en una tabla de codigos
   	IF _tipo <> "E" then -- (i) incluir los registros
   	   foreach
	   	   select codigo
		     into _codigo	
		     from tmp_codigos

		   select descripcion
			 into _nom_status
			 from statuspoli
			where cod_status = _codigo;

	   	   insert into cascampanafil(
			  cod_campana,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   values(
			  a_cod_campana,
			  _codigo,
			  8,
			  _nom_status); 
   	   end foreach;			
		  
		{else		        -- (e) excluir estos registros

		   update tmp_cob
		   	  set seleccionado = 0
			where seleccionado = 1
			  and cod_agente in (select codigo from tmp_codigos); }
	   end if
	   drop table tmp_codigos;
end if

let _codigo = "";
--proceso que ingresa los cobradores de la campana
if a_codcobra <> "*" then
	let _tipo = sp_sis04(a_codcobra);  -- separa los valores del string en una tabla de codigos
   	if _tipo <> "E" then -- (i) incluir los registros
		foreach
			select codigo
			  into _codigo
			  from tmp_codigos

			let _cod_campana = null;

			select cod_campana,
				   nombre
			  into _cod_campana,
				   _n_cobrador
			  from cobcobra
			 where cod_cobrador = _codigo;
            
			if _cod_campana <> '00000' then		  --Armando Moreno, puesto en prod 13/08/2013
				select estatus
				  into _estatus
				  from cascampana
				 where cod_campana = _cod_campana;

                {if _estatus = 2 then  --El cobrador ya tiene una campana activa, No se puede asignar otra. --Se Inactiva el control de Campañas Activas Román 20/12/2016
					return 1, "El cobrador: " || _n_cobrador || " esta en la Campaña Activa: " || _cod_campana;
				end if}
			end if

			update cobcobra
			   set cod_campana = a_cod_campana
			 where cod_cobrador = _codigo;
		end foreach;			
		  
		{else		        -- (e) excluir estos registros

		   update tmp_cob
		   	  set seleccionado = 0
			where seleccionado = 1
			  and cod_agente in (select codigo from tmp_codigos); }
	   end if
    drop table tmp_codigos;
end if

let _codigo = "";
--proceso que ingresa los filtros por grupo economico en la tabla cascampanafil
if a_codgrupo <> "*" then
	let _tipo = sp_sis04(a_codgrupo);  -- separa los valores del string en una tabla de codigos
   	if _tipo <> "E" then -- (i) incluir los registros
   	   foreach
	   	   select codigo
		     into _codigo	
		     from tmp_codigos

		   select nombre
			 into _nom_grupo
			 from cligrupo
			where cod_grupo = _codigo;

	   	   insert into cascampanafil(
			  cod_campana,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   values(
			  a_cod_campana,
			  _codigo,
			  9,
			  _nom_grupo);
	   end foreach;
	end if
	drop table tmp_codigos;
end if

let _codigo = "";
--proceso que ingresa los filtros por dias de cobros en la tabla cascampanafil
if a_codiacob <> "*" then
	let _tipo = sp_sis04(a_codiacob);  -- separa los valores del string en una tabla de codigos
   	if _tipo <> "E" then -- (i) incluir los registros
   	   foreach
	   	   select codigo
		     into _codigo	
		     from tmp_codigos

		   select descripcion
			 into _dia
			 from casdiacob
			where cod_dia = _codigo;

	   	   insert into cascampanafil(
			  cod_campana,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   values(
			  a_cod_campana,
			  _codigo,
			  10,
			  _dia);
	    end foreach;	
	end if
	drop table tmp_codigos;
end if

if a_codacre <> "*" then
   let _tipo = sp_sis04(a_codacre);  -- separa los valores del string en una tabla de codigos
   	if _tipo <> "E" then -- (i) incluir los registros
   	   foreach
	   	   select codigo
		     into _codigo	
		     from tmp_codigos

		   select descripcion
			 into _nom_acre
			 from acreehip
			where cod_acreencia = _codigo;

	   	   insert into cascampanafil(
			  cod_campana,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   values(
			  a_cod_campana,
			  _codigo,
			  11,
			  _nom_acre);
	    end foreach;	
	end if
	drop table tmp_codigos;
end if

if a_codpago <> "*" then
	let _tipo = sp_sis04(a_codpago);  -- separa los valores del string en una tabla de codigos
   	if _tipo <> "E" then -- (i) incluir los registros
   	   foreach
	   	   select codigo
		     into _codigo	
		     from tmp_codigos

		   select descripcion
			 into _nom_pago
			 from prima_orig
			where cod_pago = _codigo;

	   	   insert into cascampanafil(
			  cod_campana,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   values(
			  a_cod_campana,
			  _codigo,
			  12,
			  _nom_pago);
	    end foreach;	
	end if
	drop table tmp_codigos;
end if

if a_codespecial <> "*" then
--trace on ;
	let _dif_especiales = a_codespecial[1,1];
	let a_codespecial = a_codespecial[2,255];
	let a_codespecial = trim(a_codespecial);

	if _dif_especiales = '1' then
		insert into cascampanafil(
				  	cod_campana,
				  	cod_filtro,
				  	tipo_filtro,
				  	descripcion)
		   	values(
				  	a_cod_campana,
				  	a_codespecial,
				  	13,
				  	'1.Pólizas por Vencer');
	elif _dif_especiales = '2' then
		insert into cascampanafil(
				  	cod_campana,
				  	cod_filtro,
				  	tipo_filtro,
				  	descripcion)
		   	values(
				  	a_cod_campana,
				  	a_codespecial,
				  	13,
				  	'2.Pólizas con TCR por Vencer');
	elif _dif_especiales = '3' then
		insert into cascampanafil(
				  	cod_campana,
				  	cod_filtro,
				  	tipo_filtro,
				  	descripcion)
		   	values(
				  	a_cod_campana,
				  	'3',
				  	13,
				  	'3.Pólizas con Aviso de Cancelación');
	elif _dif_especiales = '4' then
		--trace on;
		let _tipo = sp_sis04a(a_codespecial);  -- separa los valores del string en una tabla de codigos
	   	if _tipo <> "E" then -- (i) incluir los registros
	   	   foreach
		   	   select codigo
			     into _codigo	
			     from tmp_codigos

			   insert into cascampanafil(
				  cod_campana,
				  cod_filtro,
				  tipo_filtro,
				  descripcion)
			   values(
				  a_cod_campana,
				  _codigo,
				  13,
				  '4.Rechazo de TCR y ACH');
		    end foreach;	
		end if
		drop table tmp_codigos;
	elif _dif_especiales = '5' then
		insert into cascampanafil(
				  	cod_campana,
				  	cod_filtro,
				  	tipo_filtro,
				  	descripcion)
		   	values(
				  	a_cod_campana,
				  	'5',
				  	13,
				  	'4.Pago Fijo');
	elif _dif_especiales = '6' then
		insert into cascampanafil(
				  	cod_campana,
				  	cod_filtro,
				  	tipo_filtro,
				  	descripcion)
		   	values(
				  	a_cod_campana,
				  	'6',
				  	13,
				  	'6.Pólizas Sin Pago');
	elif _dif_especiales = '7' then
		insert into cascampanafil(
				  	cod_campana,
				  	cod_filtro,
				  	tipo_filtro,
				  	descripcion)
		   	values(
				  	a_cod_campana,
				  	'7',
				  	13,
				  	'7.Recobro');
	elif _dif_especiales = '8' then
		insert into cascampanafil(
				  	cod_campana,
				  	cod_filtro,
				  	tipo_filtro,
				  	descripcion)
		   	values(
				  	a_cod_campana,
				  	'8',
				  	13,
				  	'8.Clientes VIP');					

	end if
end if

if a_codsubramo <> "*" then
	let _tipo = sp_sis04(a_codsubramo);  -- separa los valores del string en una tabla de codigos
	if _tipo <> "E" then -- (i) incluir los registros
		select cod_filtro
		  into _cod_ramo
		  from cascampanafil
		 where cod_campana = a_cod_campana
		   and tipo_filtro = 1;

		foreach
		   select codigo
		     into _codigo	
		     from tmp_codigos

		   select nombre
			 into _nom_subramo
			 from prdsubra
		   	where cod_ramo = _cod_ramo
		   	  and cod_subramo = _codigo; 

		   insert into cascampanafil(
			   cod_campana,
			   cod_filtro,
			   tipo_filtro,
			   descripcion)
		   values(
			   a_cod_campana,
			   _codigo,
			   14,
			   _nom_subramo); 
		end foreach;			
	end if
	drop table tmp_codigos;
end if

if a_codgesti <> "*" then
	insert into cascampanafil(
			    cod_campana,
			    cod_filtro,
			    tipo_filtro,
			    descripcion)
	    values(
			    a_cod_campana,
			    1,
			    15,
			    'Solo Pólizas sin Gestión'); 
end if

--------------------------   a_xperiodo  a_xtipo   a_xvencer_cdc  a_xexigible_cdc ax_anio  ax_mes  
if a_xperiodo <> "*" then

	if ax_anio is null then
		let ax_anio = '';
	end if	
	if ax_mes is null then
		let ax_mes = '';
	end if	
	if ax_mes = '' or ax_anio = '' then
	    let ls_periodo = '';
	else
		let ls_periodo = ax_anio||'-'||ax_mes;
	end if		
	
	
	let ls_periodo = ax_anio||'-'||ax_mes;
	insert into cascampanafil(
			    cod_campana,
			    cod_filtro,
			    tipo_filtro,
			    descripcion)
	    values(
			    a_cod_campana,
			    ls_periodo,
			    18,
			    'Por Periodo '||ax_anio||'-'||ax_mes ); 
end if
if a_xtipo <> "*" then
    --let li_tipo = a_xtipo;
	insert into cascampanafil(
			    cod_campana,
			    cod_filtro,
			    tipo_filtro,
			    descripcion)
	    values(
			    a_cod_campana,
			    a_xtipo,  --li_tipo,
			    19,
			    'Por Tipo '||a_xtipo); 
end if
if a_xvencer_cdc <> "*" then
	insert into cascampanafil(
			    cod_campana,
			    cod_filtro,
			    tipo_filtro,
			    descripcion)
	    values(
			    a_cod_campana,
			    '1',
			    20,
			    'Por Vencer CDC'); 
end if
if a_xexigible_cdc <> "*" then
	insert into cascampanafil(
			    cod_campana,
			    cod_filtro,
			    tipo_filtro,
			    descripcion)
	    values(
			    a_cod_campana,
			    '1',
			    21,
			    'Exigible CDC'); 
end if
--------------------------
--		drop table tmp_codigos;


return 0, "Filtros de Campañas Creados Exitosamente";

--end
end procedure


