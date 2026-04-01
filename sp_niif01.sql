-- Deterioro de Cartera NIIF
--
-- creado    : 27/02/2013 - Autor: Armando Moreno
-- sis v.2.0

--drop procedure sp_niif01;
create procedure "informix".sp_niif01(a_periodo1 char(7), a_periodo2 char(7), a_cambio_per smallint default 0)
returning   char(20),
            varchar(50),
			char(10),
			varchar(50),
			varchar(50),
			char(2),
			char(2),
			char(1),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2);

define _error_desc		char(100);
define _periodo			char(7);
define _saldo			dec(16,2);
define _por_vencer		dec(16,2);
define _corriente		dec(16,2);
define _dias_30_neto	dec(16,2);
define _dias_60_neto	dec(16,2);
define _dias_90_neto	dec(16,2);
define _dias_120_neto	dec(16,2);
define _150180_neto		dec(16,2);
define _no_documento    char(20);
define _renglon         smallint;
define _cnt             smallint;
define _porc_coaseguro  decimal(7,4); 
define _mes             char(2);
define _mes_ini         integer;
define _mes_ini_char    char(7);
--define a_periodo1       char(7);
define _no_poliza       char(10);
define _cod_tipoprod    char(3);
define _estatus_poliza  smallint;
define _cod_ramo        char(3);
define _n_ramo          varchar(50);
define _tiene_imp_ch    char(2);
define _estatus_char    char(1);
define _estado			char(2);
define _cod_grupo       char(5);
define _tiene_imp       smallint;
define _vig_fin         date;
define _cod_contratante char(10);
define _n_cliente,_n_grupo       varchar(50);
define _fecha_fin       date;

begin

set isolation to dirty read;

--set debug file to "sp_niif01.trc"; 
--trace on;


let _saldo	        = 0;
let _por_vencer	    = 0;	
let _corriente	    = 0;	
let _dias_30_neto   = 0;	
let _dias_60_neto   = 0;	
let _dias_90_neto   = 0;
let _dias_120_neto  = 0;
let _150180_neto    = 0;
let _renglon        = 0;
let _cnt            = 0;
let _porc_coaseguro = 0;

if a_cambio_per = 1 then
	delete from deivid_cob:tmp_cobmo;
end if

let _estado = 'NO';

--let a_periodo1 = '2012-09';
--let a_periodo2 = '2013-02';
let _n_cliente = "";
let _cod_contratante = null;
let _fecha_fin     = sp_sis36(a_periodo2);

if a_cambio_per = 1 then
foreach

	select no_documento,max(no_poliza)
	  into _no_documento,_no_poliza
      from deivid_cob:cobmoros2
	 where periodo >= a_periodo1
	   and periodo <= a_periodo2
	 group by no_documento

	let _renglon = 0;

	select cod_grupo,
	       estatus_poliza,
		   tiene_impuesto,
		   cod_ramo,
		   vigencia_final
	  into _cod_grupo,
	       _estatus_poliza,
		   _tiene_imp,
		   _cod_ramo,
		   _vig_fin
	  from emipomae
	 where no_poliza = _no_poliza;

    if _cod_grupo = '00000' or _cod_grupo = '1000' then  --Grupo del estado
		let _estado = 'SI';
	else
		let _estado = 'NO';
	end if

	let _n_ramo = "";

    select nombre
	  into _n_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let _estatus_char = '';

    if _vig_fin < _fecha_fin then  --Vencidas
		let _estatus_char = '*';
    end if

	let _tiene_imp_ch = '';

    if _tiene_imp = 1 then
		let _tiene_imp_ch = 'SI';
	else
		let _tiene_imp_ch = 'NO';
    end if 

	foreach
		select periodo,
			   saldo_neto,
			   por_vencer_neto,
			   corriente_neto,
			   dias_30_neto,
			   dias_60_neto,
			   dias_90_neto,
			   dias_120_neto,
			   dias_150_neto + dias_180_neto
		  into _periodo,
			   _saldo,
			   _por_vencer,
			   _corriente,
			   _dias_30_neto,
			   _dias_60_neto,
			   _dias_90_neto,
			   _dias_120_neto,
			   _150180_neto
	      from deivid_cob:cobmoros2
		 where no_documento = _no_documento
		   and periodo      >= a_periodo1
		   and periodo      <= a_periodo2
		  order by periodo

		 let _renglon = _renglon + 1;

		 BEGIN
			ON EXCEPTION IN(-268)

			 if _renglon = 2 then

				 update deivid_cob:tmp_cobmo
				    set corriente_neto = _corriente
			      where no_documento   = _no_documento;

			 elif _renglon = 3 then

				 update deivid_cob:tmp_cobmo
					set	dias_30_neto = _dias_30_neto
			      where no_documento = _no_documento;

			 elif _renglon = 4 then

				 update deivid_cob:tmp_cobmo
					set	dias_60_neto = _dias_60_neto
			      where no_documento = _no_documento;

			 elif _renglon = 5 then

				 update deivid_cob:tmp_cobmo
					set	dias_90_neto = _dias_90_neto
			      where no_documento = _no_documento;

			 elif _renglon = 6 then

				 update deivid_cob:tmp_cobmo
					set	dias_120_neto = _dias_120_neto
			      where no_documento  = _no_documento;
 
				 update deivid_cob:tmp_cobmo
					set	masde120_neto = _150180_neto
			      where no_documento  = _no_documento;

			 end if


		 END EXCEPTION 	

			 insert into deivid_cob:tmp_cobmo(
			 no_documento,
			 saldo_neto,
			 por_vencer_neto,
			 corriente_neto,
			 dias_30_neto,
			 dias_60_neto,
			 dias_90_neto,
			 dias_120_neto,
			 masde120_neto,
			 aplica_imp,
			 n_ramo,
			 estatus,
			 estado)
			 values(
			 _no_documento,
			 _saldo,
			 _por_vencer,
			 0,
			 0,
			 0,
			 0,
			 0,
			 0,
			 _tiene_imp_ch,
			 _n_ramo,
			 _estatus_char,
			 _estado
			 );

		END
	end foreach
end foreach
end if
foreach

	select no_documento,
		   saldo_neto,
		   por_vencer_neto,
		   corriente_neto,
		   dias_30_neto,
		   dias_60_neto,
		   dias_90_neto,
		   dias_120_neto,
		   masde120_neto,
		   aplica_imp,
		   n_ramo,
		   estatus,
		   estado
	  into _no_documento,
		   _saldo,
		   _por_vencer,
		   _corriente,
		   _dias_30_neto,
		   _dias_60_neto,
		   _dias_90_neto,
		   _dias_120_neto,
		   _150180_neto,
		   _tiene_imp_ch,
		   _n_ramo,
		   _estatus_char,
		   _estado
	  from deivid_cob:tmp_cobmo

   foreach
	select cod_contratante,cod_grupo
	  into _cod_contratante,_cod_grupo
	  from emipomae
	 where no_documento = _no_documento
	  
	exit foreach;
   end foreach

   select nombre
     into _n_cliente
	 from cliclien
	where cod_cliente = _cod_contratante;

   select nombre
     into _n_grupo
	 from cligrupo
	where cod_grupo = _cod_grupo;

	return _no_documento,
	       _n_ramo,
	       _cod_contratante,
		   _n_cliente,
		   _n_grupo,
	       _tiene_imp_ch,
	       _estado,
	       _estatus_char,
	       _saldo,
	       _por_vencer,
	       _corriente,
	       _dias_30_neto,
	       _dias_60_neto,
		   _dias_90_neto,
		   _dias_120_neto,
		   _150180_neto with resume;

end foreach

end
end procedure
