# note

A simple command-line note-taking script written in Bash.

## 🚀 Installation

### Clone the repository
```
git clone https://github.com/ndarash93/note.sh.git
cd note.sh
```
### Run the installer (may require sudo)
```
./install.sh
```

## 📝 Usage

### Take a quick note
```
note This is a quick note
```

### Separate notes into file
```
note -f <filename> <note>
```

### List notes
```
note -l
```
#### Output
```
=== generic.note ===
        1       2025-10-03 22:17:07 — This is a quick note
```

### Important notes
```
note -i <note>
```
Important notes will appear in red and can be listed separately

```
note -i -l
```
Will print only notes marked as imprtant
