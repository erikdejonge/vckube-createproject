# coding=utf-8
"""
callbacks
"""

FIELDS = ['cmd', 'command', 'invocation', 'msg', 'stdout', 'stderr']


def human_log(res):
    """
    @type res: str, unicode
    @return: None
    """
    if isinstance(res, type(dict())):
        first = True
        docker = False

        for field in FIELDS:
            if field in res.keys():
                if "cmd" in field:
                    if "docker images" in str(res[field]):
                        docker = True

                if "invocation" in str(field):
                    if len(res[field]["module_args"]) > 0:
                        if res[field]["module_name"] not in ["shell"]:
                            outputmsg = u'{0}: {1}\n'.format(res[field]["module_name"], str("\n" + " " * (2 + len(res[field]["module_name"]))).join(res[field]["module_args"].split()))

                            if outputmsg is not None:
                                print "\033[91m" + outputmsg, "\033[0m"
                else:
                    outputmsg = ""

                    if len(str(res[field]).strip()) > 0:
                        if not first:
                            outputmsg = "\n"

                        resfield = res[field]

                        if isinstance(resfield, list):
                            resfield = " ".join(resfield)
                        else:
                            resfield = str(resfield)

                        if docker and "stdout" in field or "command" in field:
                            outputmsg = None
                        else:
                            outputmsg += u'{0}:\n  {1}'.format(field, resfield.replace("\n", "\n  "))

                    if outputmsg is not None:
                        print "\033[91m" + outputmsg, "\033[0m"

            first = False

        # print "\033[31m", res.keys(), "\033[0m"


class CallbackModule(object):

    """
    CallbackModule
    """
    # noinspection PyMethodMayBeStatic

    def on_any(self, *args, **kwargs):
        """
        @type args: tuple
        @type kwargs: dict
        @return: None
        """

        # print "\033[92m", args, "\033[0m"
        # print "\033[95m", kwargs, "\033[0m"
        pass

    # noinspection PyMethodMayBeStatic,PyUnusedLocal,PyUnusedLocal
    def runner_on_failed(self, host, res, ignore_errors=False):
        """
        @type host: str, unicode
        @type res: str, unicode
        @type ignore_errors: bool
        @return: None
        """
        human_log(res)

    # noinspection PyMethodMayBeStatic,PyUnusedLocal
    def runner_on_ok(self, host, res):
        """
        @type host: str, unicode
        @type res: str, unicode
        @return: None
        """
        human_log(res)

    # noinspection PyMethodMayBeStatic
    def runner_on_error(self, host, msg):
        """
        @type host: str, unicode
        @type msg: str, unicode
        @return: None
        """
        pass

    # noinspection PyMethodMayBeStatic
    def runner_on_skipped(self, host, item=None):
        """
        @type host: str, unicode
        @type item: str, unicode, None
        @return: None
        """
        pass

    # noinspection PyMethodMayBeStatic,PyUnusedLocal
    def runner_on_unreachable(self, host, res):
        """
        @type host: str, unicode
        @type res: str, unicode
        @return: None
        """
        human_log(res)

    # noinspection PyMethodMayBeStatic
    def runner_on_no_hosts(self):
        """
        runner_on_no_hosts
        """
        pass

    # noinspection PyMethodMayBeStatic,PyUnusedLocal,PyUnusedLocal,PyUnusedLocal
    def runner_on_async_poll(self, host, res, jid, clock):
        """
        @type host: str, unicode
        @type res: str, unicode
        @type jid: str, unicode
        @type clock: str, unicode
        @return: None
        """
        human_log(res)

    # noinspection PyMethodMayBeStatic,PyUnusedLocal,PyUnusedLocal
    def runner_on_async_ok(self, host, res, jid):
        """
        @type host: str, unicode
        @type res: str, unicode
        @type jid: str, unicode
        @return: None
        """
        human_log(res)

    # noinspection PyMethodMayBeStatic,PyUnusedLocal,PyUnusedLocal
    def runner_on_async_failed(self, host, res, jid):
        """
        @type host: str, unicode
        @type res: str, unicode
        @type jid: str, unicode
        @return: None
        """
        human_log(res)

    # noinspection PyMethodMayBeStatic
    def playbook_on_start(self):
        """
        playbook_on_start
        """
        pass

    # noinspection PyMethodMayBeStatic
    def playbook_on_notify(self, host, handler):
        """
        @type host: str, unicode
        @type handler: str, unicode
        @return: None
        """
        pass

    # noinspection PyMethodMayBeStatic
    def playbook_on_no_hosts_matched(self):
        """
        playbook_on_no_hosts_matched
        """
        pass

    # noinspection PyMethodMayBeStatic
    def playbook_on_no_hosts_remaining(self):
        """
        playbook_on_no_hosts_remaining
        """
        pass

    # noinspection PyMethodMayBeStatic
    def playbook_on_task_start(self, name, is_conditional):
        """
        @type name: str, unicode
        @type is_conditional: str, unicode
        @return: None
        """
        pass

    # noinspection PyMethodMayBeStatic
    def playbook_on_vars_prompt(self, varname, private=True, prompt=None, encrypt=None, confirm=False, salt_size=None, salt=None, default=None):
        """
        @type varname: str, unicode
        @type private: bool
        @type prompt: str, unicode, None
        @type encrypt: str, unicode, None
        @type confirm: bool
        @type salt_size: int, None
        @type salt: str, unicode, None
        @type default: str, unicode, None
        @return: None
        """
        pass

    # noinspection PyMethodMayBeStatic
    def playbook_on_setup(self):
        """
        playbook_on_setup
        """
        pass

    # noinspection PyMethodMayBeStatic
    def playbook_on_import_for_host(self, host, imported_file):
        """
        @type host: str, unicode
        @type imported_file: str, unicode
        @return: None
        """
        pass

    # noinspection PyMethodMayBeStatic
    def playbook_on_not_import_for_host(self, host, missing_file):
        """
        @type host: str, unicode
        @type missing_file: str, unicode
        @return: None
        """
        pass

    # noinspection PyMethodMayBeStatic
    def playbook_on_play_start(self, pattern):
        """
        @type pattern: str, unicode
        @return: None
        """
        pass

    # noinspection PyMethodMayBeStatic
    def playbook_on_stats(self, stats):
        """
        @type stats: str, unicode
        @return: None
        """
        pass
