drop procedure sp_act_cli_roman;
create procedure sp_act_cli_roman()
returning integer,varchar(250);

BEGIN
define _error_desc					varchar(250);
define _error_isam					integer;
define _error						integer;
define _aseg_primer_nom             varchar(100);
define _cod_cliente                 char(10);
define _aseg_segundo_nom,_aseg_primer_ape,_aseg_segundo_ape,_aseg_casada_ape varchar(40);
define _cantidad integer;

on exception set _error,_error_isam,_error_desc
	rollback work;
	let _error_desc = trim(_error_desc) || ' cod_cliente: ' || _cod_cliente;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario19.trc";
--trace on;

set isolation to dirty read;

let _cantidad = 0;
foreach with hold
	select cli.cod_cliente,
		   tmp.aseg_primer_nom,
		   tmp.aseg_segundo_nom,
		   tmp.aseg_primer_ape,
		   tmp.aseg_segundo_ape,
		   tmp.aseg_casada_ape
	  into _cod_cliente,
	       _aseg_primer_nom,
		   _aseg_segundo_nom,
		   _aseg_primer_ape,
		   _aseg_segundo_ape,
		   _aseg_casada_ape
	  from deivid_tmp:carga_corp_cred tmp
	  inner join emipomae emi on emi.no_poliza = tmp.no_poliza
	  inner join cliclien cli on cli.cod_cliente = emi.cod_contratante
	  where cli.aseg_primer_ape = ''
	  order by emi.vigencia_inic,cli.aseg_primer_ape

	begin work;

    update cliclien
	   set aseg_primer_nom  = _aseg_primer_nom,
	       aseg_segundo_nom = _aseg_segundo_nom,
	       aseg_primer_ape  = _aseg_primer_ape,
	       aseg_segundo_ape = _aseg_segundo_ape,
	       aseg_casada_ape  = _aseg_casada_ape
	 where cod_cliente = _cod_cliente;
	 
	 let _cantidad = _cantidad + 1;
 
	commit work;

end foreach

return _cantidad,'Clientes Actualizados.';
end			
end procedure;