const { promises: fs } = require("fs");

const start = async () => {
    const [file] = process.argv.slice(2);
    if (!file) {
        throw new Error("Invalid file argument");
    }
    let content = await fs.readFile(file, "utf-8");
    content = applyPatch(
        "parsedDate patch",
        content,
        /\n(\s+)(var.*\s+transaction_journal_id:\s+[^\.]\.transaction_journal_id,\s+description:\s+[^\.]\.description,)/,
        (match, space, declaration) => `\n${space}let parsedDate = moment.parseZone(e.date);\n${space}${declaration}`
    );
    content = applyPatch(
        "date & dateOffset patch",
        content,
        /\n(\s+)(description:\s+[^\.]\.description,)\s+date:\s+[^\.]\.date\.substring\(0,\s+16\),\s+(reconciled:\s+[^\.]\.reconciled,)/,
        (match, space, description, reconciled) => `\n${space}${description}\n${space}dateOffsetTarget: parsedDate.utcOffset(),\n${space}date: parsedDate.local().format().substring(0, 16),\n${space}${reconciled}`
    );
    await fs.writeFile(file, content, "utf-8");
};

/**
 * @param {string} name Name of the patch
 * @param {string} content Content to apply the patch to
 * @param {RegExp} regex Regular expression to match the content to be replaced
 * @param {Parameters<typeof String.prototype.replace>[1]} replacement Function that returns the replacement string
 * @returns {string} Patched content
 */
const applyPatch = (name, content, regex, replacement) => {
    let replaced = false;
    content = content.replace(regex, (...args) => {
        replaced = true;
        return replacement(...args);
    });
    if (!replaced) {
        throw new Error("Failed to apply patch: " + name);
    }
    return content;
};

start();
